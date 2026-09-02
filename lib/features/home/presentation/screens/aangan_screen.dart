import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../../core/utils/profile_pro_upgrade_nav.dart';
import '../../../sanctuary/data/models/sanctuary_customization_model.dart';
import '../../../sanctuary/data/services/sanctuary_customization_service.dart';
import '../../../sanctuary/presentation/widgets/customizable_om_sanctuary.dart';
import '../../../sanctuary/presentation/widgets/sanctuary_shop_sheet.dart';
import '../../data/services/asset_server.dart';
import '../../../navigation/presentation/providers/main_navigation_intent_provider.dart';
import '../../../../core/services/day_night_service.dart';
import '../../../../core/utils/sound_manager.dart';
/// Redesigned Aangan Screen with Customizable Om Sanctuary
/// Features:
/// - Top 40%: Customizable Om Sanctuary with live preview
/// - Bottom 60%: Draggable shop UI for purchasing customizations
/// - One-way sync to Ashram screen
class AanganScreen extends ConsumerStatefulWidget {
  /// When true, this tab is visible; used to refetch notifications when user returns to Aangan.
  final bool isActive;

  const AanganScreen({
    super.key,
    this.isActive = true,
  });

  @override
  ConsumerState<AanganScreen> createState() => _AanganScreenState();
}

class _AanganScreenState extends ConsumerState<AanganScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  ProviderSubscription<int?>? _aanganPendingTabSubscription;

  final CoinService _coinService = CoinService();
  final SanctuaryCustomizationService _customizationService =
      SanctuaryCustomizationService();
  // Avatar repository removed — stats shown in Profile tab only

  // The actual applied customization (nullable until loaded)
  SanctuaryCustomization? _appliedCustomization;
  // The preview customization (shown while browsing items)
  SanctuaryCustomization? _previewCustomization;
  // Whether we're in preview mode
  bool _isPreviewMode = false;
  // Stream subscription
  StreamSubscription<SanctuaryCustomization>? _customizationSubscription;
  // Loading state
  bool _customizationLoaded = false;

  // Aatma (sanctuary) vs Mandir: 0 = Aatma, 1 = Mandir
  int _aanganTabIndex = 0;
  /// Mandir tab: [MandirItems.mandirView] ids → same WebView; JS swaps temple / Shiv Ling / per-deity murti.
  String _mandirViewId = MandirItems.idSacredTemple;

  // Loopback HTTP server + WebView: GLTFLoader needs http XHR; file:// is blocked on WKWebView.
  final AssetServer _assetServer = AssetServer();
  WebViewController? _mandirWebViewController;
  bool _mandirServerStarted = false;

  /// Night at user location => stars + dark sky; day => normal sky, no stars.
  bool? _isNight;

  // Sheet minimized state (no controller to avoid "already attached" when rebuilt)
  bool _isAatmaSheetMinimized = true;
  bool _isMandirSheetMinimized = true;

  // Pro: Mandir 3D available; non-Pro: show blurred lock (no WebView = no animation runs)
  bool _isPremium = false;
  StreamSubscription<bool>? _premiumSubscription;

  static const double _sheetMinSize = 0.065;
  static const double _sheetMidSize = 0.45;

  /// Profile mute + volume → Mandir WebView Aarti [HTMLAudioElement].
  late final Listenable _mandirSoundPrefsListenable = Listenable.merge([
    SoundManager().backgroundSoundEnabled,
    SoundManager().backgroundVolume,
  ]);

  SanctuaryCustomization get _displayCustomization =>
      _previewCustomization ??
      _appliedCustomization ??
      SanctuaryCustomization.defaultConfig;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _customizationLoaded = true;
    PremiumService.instance.isPremium.then((v) {
      if (mounted) setState(() => _isPremium = v);
    });
    _premiumSubscription = PremiumService.instance.premiumStatusStream.listen((v) {
      if (mounted) setState(() => _isPremium = v);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices();
      if (!mounted) return;
      if (!MandirItems.isValidMandirViewId(_mandirViewId)) {
        setState(() => _mandirViewId = MandirItems.idSacredTemple);
      }
    });
    _mandirSoundPrefsListenable.addListener(_syncMandirWebViewBackgroundMusic);

    _aanganPendingTabSubscription =
        ref.listenManual<int?>(aanganPendingTabProvider, (previous, tab) {
      if (tab == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(aanganPendingTabProvider.notifier).state = null;
        setState(() {
          _aanganTabIndex = tab;
          if (tab == 1) {
            _isMandirSheetMinimized = false;
            if (_isPremium) {
              _ensureMandirServer();
              Future.delayed(const Duration(milliseconds: 400), () {
                if (!mounted) return;
                _applyMandirStructureToWebView();
                if (_mandirViewId == MandirItems.idSacredTemple) {
                  _mandirWebViewController?.runJavaScript(
                    "if(typeof mandirEntryZoom==='function')mandirEntryZoom();",
                  );
                }
              });
            }
          }
        });
      });
    });
  }

  void _syncMandirWebViewBackgroundMusic() {
    final sm = SoundManager();
    final on = sm.backgroundSoundEnabled.value;
    final vol = sm.backgroundVolume.value;
    _mandirWebViewController?.runJavaScript(
      '(function(){'
      "if(typeof setMandirBackgroundMusicEnabled==='function')setMandirBackgroundMusicEnabled(${on ? 'true' : 'false'});"
      "if(typeof setMandirBackgroundMusicVolume==='function')setMandirBackgroundMusicVolume($vol);"
      '})();',
    );
  }

  @override
  void didUpdateWidget(covariant AanganScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive && mounted) {
      setState(() {
        _isAatmaSheetMinimized = true;
        _isMandirSheetMinimized = true;
      });
      _setMandirScenePaused(false);
    } else if (!widget.isActive && oldWidget.isActive) {
      _setMandirScenePaused(true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _aanganPendingTabSubscription?.close();
    _mandirSoundPrefsListenable.removeListener(_syncMandirWebViewBackgroundMusic);
    _customizationSubscription?.cancel();
    _premiumSubscription?.cancel();
    if (_mandirServerStarted && !kIsWeb) _assetServer.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _setMandirScenePaused(true);
        break;
      case AppLifecycleState.resumed:
        _setMandirScenePaused(false);
        break;
    }
  }

  void _setMandirScenePaused(bool paused) {
    final fn = paused ? 'pauseMandirScene' : 'resumeMandirScene';
    _mandirWebViewController?.runJavaScript(
      "if(typeof $fn==='function')$fn();",
    );
  }

  void _minimizeAatmaSheet() {
    if (mounted) setState(() => _isAatmaSheetMinimized = true);
  }

  void _expandAatmaSheet() {
    if (mounted) setState(() => _isAatmaSheetMinimized = false);
  }

  void _minimizeMandirSheet() {
    if (mounted) setState(() => _isMandirSheetMinimized = true);
  }

  void _expandMandirSheet() {
    if (mounted) setState(() => _isMandirSheetMinimized = false);
  }

  Future<void> _initializeServices() async {
    _coinService.initialize();

    _customizationSubscription?.cancel();
    _customizationSubscription =
        _customizationService.customizationStream.listen((customization) {
      if (mounted) {
        setState(() {
          _appliedCustomization = customization;
          _customizationLoaded = true;
          _previewCustomization = null;
          _isPreviewMode = false;
        });
      }
    });

    await _customizationService.ensureInitialized();

    final isNight = await DayNightService.instance.isNightTime();
    if (mounted) {
      setState(() {
        _appliedCustomization = _customizationService.currentCustomization;
        _customizationLoaded = true;
        _isNight = isNight;
      });
    }
  }

  void _onPreviewChange(SanctuaryCustomization preview) {
    setState(() {
      _previewCustomization = preview;
      _isPreviewMode = true;
    });
  }

  void _onPreviewClear() {
    setState(() {
      _previewCustomization = null;
      _isPreviewMode = false;
    });
  }

  void _onApplied(SanctuaryCustomization applied) {
    setState(() {
      _appliedCustomization = applied;
      _previewCustomization = null;
      _isPreviewMode = false;
    });
  }

  void _onMandirAction(String jsCall) {
    _mandirWebViewController?.runJavaScript(jsCall);
  }

  void _applyMandirStructureToWebView() {
    final js = MandirItems.mandirStructureViewJsArg(_mandirViewId);
    _mandirWebViewController?.runJavaScript(
      "if(typeof setMandirStructureView==='function')setMandirStructureView('$js');",
    );
  }

  void _onMandirViewFromShop(String id) {
    setState(() => _mandirViewId = id);
    _ensureMandirServer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyMandirStructureToWebView();
      if (id == MandirItems.idSacredTemple) {
        Future.delayed(const Duration(milliseconds: 320), () {
          if (!mounted || _mandirViewId != MandirItems.idSacredTemple) return;
          _mandirWebViewController?.runJavaScript(
            "if(typeof mandirEntryZoom==='function')mandirEntryZoom();",
          );
        });
      }
    });
  }

  void _ensureMandirServer() {
    if (_mandirServerStarted || kIsWeb) return;
    _mandirServerStarted = true;
    _assetServer.start().then((_) async {
      if (!mounted) return;
      final port = _assetServer.port;
      final controller = WebViewController();
      controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      // Avoid setBackgroundColor to prevent UIColor pigeon channel error on iOS
      controller.setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            await _customizationService.ensureInitialized();
            final ground = _customizationService.templeGroundType;
            controller.runJavaScript("setFloor('${ground.name}',null)");
            final lightId = _customizationService.mandirLightId;
            final lightMatch = MandirItems.light.where((e) => e.id == lightId).toList();
            if (lightMatch.isNotEmpty) {
              controller.runJavaScript(lightMatch.first.jsCall);
            } else {
              controller.runJavaScript("mood('midday',null)");
            }
            final deityBg = _customizationService.mandirDeityBackground;
            if (deityBg != null && deityBg.isNotEmpty && deityBg != 'none') {
              controller.runJavaScript("setDeityBackground('$deityBg')");
            }
            final structureJs = MandirItems.mandirStructureViewJsArg(_mandirViewId);
            controller.runJavaScript(
              "if(typeof setMandirStructureView==='function')setMandirStructureView('$structureJs');",
            );
            _syncMandirWebViewBackgroundMusic();
          },
        ),
      );
      // 127.0.0.1 loopback only — avoids NSLocalNetworkUsageDescription while
      // satisfying GLTFLoader (file:// XHR is blocked in WKWebView).
      await controller.loadRequest(Uri.parse('http://127.0.0.1:$port/'));
      if (mounted) {
        setState(() {
          _mandirWebViewController = controller;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topHeight = screenHeight * 0.62;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      body: SafeArea(
        child: _aanganTabIndex == 0
            ? _buildAatmaLayout(topHeight)
            : _buildMandirLayout(),
      ),
    );
  }

  Widget _buildAatmaLayout(double topHeight) {
    // Run animations when Aangan (Aatma) tab is active; pause when user switches to another main tab.
    final animationsEnabled = widget.isActive;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
            child: _AuroraBackground(isNight: _isNight ?? true, animate: animationsEnabled)),
        if (_isNight != false) ...[
          Positioned.fill(child: _AnimatedGeometryOverlay(animate: animationsEnabled)),
          Positioned.fill(child: _ShiningStars(animate: animationsEnabled)),
          Positioned.fill(child: _FallingStars(animate: animationsEnabled)),
        ],
        Positioned.fill(child: _AmbientParticles(animate: animationsEnabled)),
        Positioned.fill(child: _FloatingLotusPetals(animate: animationsEnabled)),

        Positioned(
          top: 0, left: 0, right: 0, height: topHeight,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildAatmaMandirTabBar(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _TouchRippleLayer(
                  onTap: _minimizeAatmaSheet,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Fill entire area so tap/ripple never shifts layout; content centered
                      Positioned.fill(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _GodRays(animate: animationsEnabled),
                            _EnergyPulseWaves(animate: animationsEnabled),
                            if (_customizationLoaded)
                              CustomizableOmSanctuary(
                                size: 280,
                                customization: _displayCustomization,
                                animate: animationsEnabled,
                              ),
                          ],
                        ),
                      ),
                      if (_isPreviewMode)
                        Positioned(
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9933)
                                  .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.visibility,
                                    size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'PREVIEW MODE',
                                  style: GoogleFonts.tenorSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Aatma shop sheet
        Positioned.fill(
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              if (mounted) {
                final isMin = notification.extent <= _sheetMinSize + 0.02;
                if (isMin != _isAatmaSheetMinimized) {
                  setState(() => _isAatmaSheetMinimized = isMin);
                }
              }
              return false;
            },
            child: DraggableScrollableSheet(
              key: const ValueKey('aatma_sheet'),
              initialChildSize: _isAatmaSheetMinimized ? _sheetMinSize : _sheetMidSize,
              minChildSize: _sheetMinSize,
              maxChildSize: 0.95,
              snap: true,
              snapSizes: const [0.065, 0.12, 0.45, 0.65, 0.95],
              builder: (context, scrollController) {
                return SanctuaryShopSheet(
                  scrollController: scrollController,
                  isMinimized: _isAatmaSheetMinimized,
                  aanganTab: AanganTab.aatma,
                  onMinimizeTap: _minimizeAatmaSheet,
                  onExpandTap: _expandAatmaSheet,
                  onPreviewChange: _onPreviewChange,
                  onPreviewClear: _onPreviewClear,
                  onApplied: _onApplied,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMandirLayout() {
    // Non-Pro: show blurred lock only — no WebView, so no 3D/animation code runs
    if (!_isPremium) {
      return _buildMandirProLockedLayout();
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        // 3D WebView: temple / Shiv Ling / deity murti planes — setMandirStructureView in aangan_3d.html.
        Positioned.fill(
          child: _mandirWebViewController != null
              ? WebViewWidget(controller: _mandirWebViewController!)
              : ColoredBox(
                  color: const Color(0xFF0B1623),
                  child: Center(
                    child: Text(
                      'Loading Mandir...',
                      style: GoogleFonts.tenorSans(
                        fontSize: 13,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ),
        ),

        // Tab bar floating on top
        Positioned(
          top: 12, left: 24, right: 24,
          child: _buildAatmaMandirTabBar(),
        ),

        // Tap on 3D area minimizes options sheet (translucent so WebView also receives events)
        Positioned.fill(
          child: _MandirTapToMinimizeOverlay(onMinimize: _minimizeMandirSheet),
        ),

        // Mandir shop sheet
        Positioned.fill(
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              if (mounted) {
                final isMin = notification.extent <= _sheetMinSize + 0.02;
                if (isMin != _isMandirSheetMinimized) {
                  setState(() => _isMandirSheetMinimized = isMin);
                }
              }
              return false;
            },
            child: DraggableScrollableSheet(
              key: const ValueKey('mandir_sheet'),
              initialChildSize: _isMandirSheetMinimized ? _sheetMinSize : _sheetMidSize,
              minChildSize: _sheetMinSize,
              maxChildSize: 0.95,
              snap: true,
              snapSizes: const [0.065, 0.12, 0.45, 0.65, 0.95],
              builder: (context, scrollController) {
                return SanctuaryShopSheet(
                  scrollController: scrollController,
                  isMinimized: _isMandirSheetMinimized,
                  aanganTab: AanganTab.mandir,
                  onMinimizeTap: _minimizeMandirSheet,
                  onExpandTap: _expandMandirSheet,
                  onMandirAction: _onMandirAction,
                  onGroundTypeChange: (_) {},
                  mandirViewSelectionId: _mandirViewId,
                  onMandirViewSelected: _onMandirViewFromShop,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Minimal placeholder (no full Pro gate page). Banner + dialog come from Mandir tab tap.
  Widget _buildMandirProLockedLayout() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.ashramBackgroundDark,
                  const Color(0xFF152535),
                  AppColors.ashramBackgroundDark,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 120,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Icon(
                  Icons.temple_hindu_rounded,
                  size: 56,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  '3D Mandir',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Available with Pro — open Profile to upgrade.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.35,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 24,
          right: 24,
          child: _buildAatmaMandirTabBar(),
        ),
      ],
    );
  }

  /// Tab bar: Aatma | Mandir
  Widget _buildAatmaMandirTabBar() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TabBarTab(
              label: 'AATMA',
              isActive: _aanganTabIndex == 0,
              onTap: () => setState(() => _aanganTabIndex = 0),
            ),
            const SizedBox(width: 2),
            _TabBarTab(
              label: 'MANDIR',
              isActive: _aanganTabIndex == 1,
              isLocked: !_isPremium,
              onTap: () {
                if (!_isPremium) {
                  setState(() => _aanganTabIndex = 1);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    navigateToProfileForProUpgrade(
                      context,
                      message:
                          'The immersive 3D Mandir, aarti, and décor options are included with Pro. Open Profile to view plans.',
                    );
                  });
                  return;
                }
                _ensureMandirServer();
                setState(() => _aanganTabIndex = 1);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Future.delayed(const Duration(milliseconds: 400), () {
                    if (!mounted) return;
                    _applyMandirStructureToWebView();
                    if (_mandirViewId == MandirItems.idSacredTemple) {
                      _mandirWebViewController?.runJavaScript(
                        "if(typeof mandirEntryZoom==='function')mandirEntryZoom();",
                      );
                    }
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Overlay that minimizes Mandir sheet on tap only; translucent so WebView still receives drags.
class _MandirTapToMinimizeOverlay extends StatefulWidget {
  final VoidCallback onMinimize;

  const _MandirTapToMinimizeOverlay({required this.onMinimize});

  @override
  State<_MandirTapToMinimizeOverlay> createState() =>
      _MandirTapToMinimizeOverlayState();
}

class _MandirTapToMinimizeOverlayState extends State<_MandirTapToMinimizeOverlay> {
  Offset? _downPosition;
  DateTime? _downTime;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) {
        _downPosition = e.localPosition;
        _downTime = DateTime.now();
      },
      onPointerUp: (e) {
        if (_downPosition == null || _downTime == null) return;
        final dist = (e.localPosition - _downPosition!).distance;
        final elapsed = DateTime.now().difference(_downTime!).inMilliseconds;
        if (dist < 18 && elapsed < 400) widget.onMinimize();
        _downPosition = null;
        _downTime = null;
      },
      onPointerCancel: (_) {
        _downPosition = null;
        _downTime = null;
      },
      child: const SizedBox.expand(),
    );
  }
}

/// Single tab: gold text + short underline when active, grey when inactive
class _TabBarTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isLocked;

  const _TabBarTab({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.ashramAccentGold.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLocked) ...[
                    Icon(Icons.lock, size: 10, color: isActive ? AppColors.ashramAccentGold : Colors.white54),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.tenorSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: isActive
                          ? AppColors.ashramAccentGold
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              if (isActive) ...[
                const SizedBox(height: 3),
                Container(
                  width: 20,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.ashramAccentGold,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LAYER 0: AURORA / NEBULA BACKGROUND — Mesmerizing color-shifting backdrop
// ═══════════════════════════════════════════════════════════════════════════

class _AuroraBackground extends StatefulWidget {
  final bool isNight;
  final bool animate;

  const _AuroraBackground({this.isNight = true, this.animate = true});

  @override
  State<_AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<_AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.animate) {
        _ctrl.repeat();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _AuroraBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _ctrl.repeat();
      } else {
        _ctrl.stop();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _AuroraPainter(
              progress: _ctrl.value,
              isNight: widget.isNight,
            ),
          );
        },
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double progress;
  final bool isNight;
  _AuroraPainter({required this.progress, this.isNight = true});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isNight) {
      _paintDaySky(canvas, size);
      return;
    }
    final cx = size.width / 2;
    final cy = size.height * 0.35;
    final t = progress * 2 * pi;

    // Nebula cloud 1 — deep indigo, shifts position slowly
    final offset1 = Offset(cx + sin(t) * 60, cy + cos(t * 0.7) * 40);
    final gradient1 = ui.Gradient.radial(
      offset1,
      size.width * 0.55,
      [
        const Color(0xFF1B0A3C).withValues(alpha: 0.6),
        const Color(0xFF0D1B2A).withValues(alpha: 0.0),
      ],
    );
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..shader = gradient1
          ..blendMode = BlendMode.screen);

    // Nebula cloud 2 — warm saffron glow behind Om area
    final offset2 = Offset(cx + cos(t * 0.5) * 40, cy + sin(t * 0.3) * 30);
    final gradient2 = ui.Gradient.radial(
      offset2,
      size.width * 0.4,
      [
        const Color(0xFFD4AF37).withValues(alpha: 0.06),
        const Color(0xFF0B1623).withValues(alpha: 0.0),
      ],
    );
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), Paint()..shader = gradient2);
  }

  /// Day/morning: black background (same as night) so UI is consistent and text stays visible.
  void _paintDaySky(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0B1623),
    );
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.progress != progress || old.isNight != isNight;
}

// ═══════════════════════════════════════════════════════════════════════════
// LAYER: SHINING STARS — Twinkling starfield (Aatma section)
// ═══════════════════════════════════════════════════════════════════════════

class _ShiningStars extends StatefulWidget {
  final bool animate;

  const _ShiningStars({this.animate = true});

  @override
  State<_ShiningStars> createState() => _ShiningStarsState();
}

class _ShiningStarsState extends State<_ShiningStars>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Star> _stars;
  final _rng = Random(123);

  @override
  void initState() {
    super.initState();
    _stars = List.generate(55, (_) => _Star(_rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.animate) {
        _ctrl.repeat();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _ShiningStars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _ctrl.repeat();
      } else {
        _ctrl.stop();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _ShiningStarsPainter(
              stars: _stars,
              time: _ctrl.value,
            ),
          );
        },
      ),
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double phase;
  final double twinkleSpeed;

  _Star(Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble() * 0.65,
        size = 0.8 + rng.nextDouble() * 1.8,
        phase = rng.nextDouble() * 2 * pi,
        twinkleSpeed = 2 + rng.nextDouble() * 4;
}

class _ShiningStarsPainter extends CustomPainter {
  final List<_Star> stars;
  final double time;

  _ShiningStarsPainter({required this.stars, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final t = time * 2 * pi;
      final twinkle = (sin(t * s.twinkleSpeed + s.phase) + 1) / 2;
      final opacity = 0.2 + 0.6 * twinkle;
      final paint = Paint()
        ..color = Color.fromRGBO(255, 252, 240, opacity.clamp(0.0, 1.0));
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShiningStarsPainter old) => old.time != time;
}

// ═══════════════════════════════════════════════════════════════════════════
// LAYER: FALLING STARS — Occasional shooting stars (Aatma section)
// ═══════════════════════════════════════════════════════════════════════════

class _FallingStars extends StatefulWidget {
  final bool animate;

  const _FallingStars({this.animate = true});

  @override
  State<_FallingStars> createState() => _FallingStarsState();
}

class _FallingStarsState extends State<_FallingStars>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_ShootingStar> _shooters;
  final _rng = Random(456);

  @override
  void initState() {
    super.initState();
    _shooters = List.generate(5, (_) => _ShootingStar(_rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.animate) {
        _ctrl.repeat();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _FallingStars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _ctrl.repeat();
      } else {
        _ctrl.stop();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _FallingStarsPainter(
              shooters: _shooters,
              time: _ctrl.value,
            ),
          );
        },
      ),
    );
  }
}

class _ShootingStar {
  final double startX;
  final double startY;
  final double angle; // direction of fall (radians)
  final double length;
  final double durationPhase; // 0..1 offset so not all fire at once
  final double speed;

  _ShootingStar(Random rng)
      : startX = rng.nextDouble(),
        startY = rng.nextDouble() * 0.35,
        angle = pi / 2 + (rng.nextDouble() - 0.5) * 0.5,
        length = 40 + rng.nextDouble() * 50,
        durationPhase = rng.nextDouble(),
        speed = 0.15 + rng.nextDouble() * 0.12;
}

class _FallingStarsPainter extends CustomPainter {
  final List<_ShootingStar> shooters;
  final double time;

  _FallingStarsPainter({required this.shooters, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final maxTravel = size.width + size.height;
    const segments = 12;
    for (final s in shooters) {
      final cycle = (time + s.durationPhase) % 1.0;
      if (cycle > 0.78) continue;
      final t = cycle / 0.78;
      final headX = (s.startX * size.width + cos(s.angle) * t * maxTravel);
      final headY = (s.startY * size.height + sin(s.angle) * t * maxTravel);
      final head = Offset(headX, headY);
      final tail = Offset(
        head.dx - cos(s.angle) * s.length,
        head.dy - sin(s.angle) * s.length,
      );
      final fade = t < 0.08 ? t / 0.08 : (t > 0.92 ? (1 - t) / 0.08 : 1.0);
      final opacity = (0.95 * fade).clamp(0.0, 1.0);
      final glowOpacity = (0.4 * fade).clamp(0.0, 1.0);
      for (int i = 0; i < segments; i++) {
        final u0 = i / segments;
        final u1 = (i + 1) / segments;
        final p0 = Offset(
          tail.dx + (head.dx - tail.dx) * u0,
          tail.dy + (head.dy - tail.dy) * u0,
        );
        final p1 = Offset(
          tail.dx + (head.dx - tail.dx) * u1,
          tail.dy + (head.dy - tail.dy) * u1,
        );
        final w = 0.15 + 1.35 * u1;
        final glowW = w + 4;
        final paint = Paint()
          ..color = Color.fromRGBO(255, 252, 245, opacity)
          ..strokeWidth = w
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        canvas.drawLine(p0, p1, paint);
        final glowPaint = Paint()
          ..color = Color.fromRGBO(255, 252, 245, glowOpacity * 0.5)
          ..strokeWidth = glowW
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawLine(p0, p1, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FallingStarsPainter old) => old.time != time;
}

// ═══════════════════════════════════════════════════════════════════════════
// LAYER 1: ANIMATED SACRED GEOMETRY — Slowly rotating golden grid
// ═══════════════════════════════════════════════════════════════════════════

class _AnimatedGeometryOverlay extends StatefulWidget {
  final bool animate;

  const _AnimatedGeometryOverlay({this.animate = true});

  @override
  State<_AnimatedGeometryOverlay> createState() =>
      _AnimatedGeometryOverlayState();
}

class _AnimatedGeometryOverlayState extends State<_AnimatedGeometryOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120), // Very slow rotation
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.animate) {
        _ctrl.repeat();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _AnimatedGeometryOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _ctrl.repeat();
      } else {
        _ctrl.stop();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _AnimatedGeometryPainter(
              rotation: _ctrl.value * 2 * pi,
              pulse: (sin(_ctrl.value * 2 * pi * 3) + 1) / 2,
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedGeometryPainter extends CustomPainter {
  final double rotation;
  final double pulse; // 0..1

  _AnimatedGeometryPainter({required this.rotation, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.35;

    // Concentric sacred circles around the Om area
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var i = 0; i < 3; i++) {
      final radius = 100.0 + i * 55 + pulse * 6;
      circlePaint.color =
          Color.fromRGBO(212, 175, 55, 0.04 - i * 0.01);
      canvas.drawCircle(Offset(cx, cy), radius, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedGeometryPainter old) =>
      old.rotation != rotation || old.pulse != pulse;
}

// ═══════════════════════════════════════════════════════════════════════════
// LAYER 2: AMBIENT GOLDEN PARTICLES — Floating dust motes across screen
// ═══════════════════════════════════════════════════════════════════════════

class _AmbientParticles extends StatefulWidget {
  final bool animate;

  const _AmbientParticles({this.animate = true});

  @override
  State<_AmbientParticles> createState() => _AmbientParticlesState();
}

class _AmbientParticlesState extends State<_AmbientParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_DustParticle> _particles;
  final _rng = Random(42);

  @override
  void initState() {
    super.initState();
    _particles = List.generate(14, (_) => _DustParticle(_rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.animate) {
        _ctrl.repeat();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _AmbientParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _ctrl.repeat();
      } else {
        _ctrl.stop();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _AmbientParticlePainter(
              particles: _particles,
              time: _ctrl.value,
            ),
          );
        },
      ),
    );
  }
}

class _DustParticle {
  late double x, y, speed, size, phase, wobbleAmp, wobbleFreq;
  late double opacity;

  _DustParticle(Random rng) {
    x = rng.nextDouble();
    y = rng.nextDouble();
    speed = 0.02 + rng.nextDouble() * 0.04;
    size = 1.0 + rng.nextDouble() * 2.5;
    phase = rng.nextDouble() * 2 * pi;
    wobbleAmp = 0.005 + rng.nextDouble() * 0.015;
    wobbleFreq = 1 + rng.nextDouble() * 2;
    opacity = 0.15 + rng.nextDouble() * 0.4;
  }
}

class _AmbientParticlePainter extends CustomPainter {
  final List<_DustParticle> particles;
  final double time;

  _AmbientParticlePainter({required this.particles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = time * 2 * pi;
      // Move upward slowly, wrap around
      final py = (p.y - time * p.speed) % 1.0;
      final px = p.x + sin(t * p.wobbleFreq + p.phase) * p.wobbleAmp;

      // Fade near edges
      final edgeFade = (py < 0.1 ? py / 0.1 : py > 0.9 ? (1 - py) / 0.1 : 1.0);
      final alpha = p.opacity * edgeFade * (0.7 + 0.3 * sin(t * 0.5 + p.phase));

      final paint = Paint()
        ..color = Color.fromRGBO(244, 228, 182, alpha.clamp(0.0, 1.0));

      canvas.drawCircle(
        Offset(px * size.width, py * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientParticlePainter old) =>
      old.time != time;
}

// ═══════════════════════════════════════════════════════════════════════════
// LAYER 3: FLOATING LOTUS PETALS — Delicate petals drifting across screen
// ═══════════════════════════════════════════════════════════════════════════

class _FloatingLotusPetals extends StatefulWidget {
  final bool animate;

  const _FloatingLotusPetals({this.animate = true});

  @override
  State<_FloatingLotusPetals> createState() => _FloatingLotusPetalsState();
}

class _FloatingLotusPetalsState extends State<_FloatingLotusPetals>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_LotusPetal> _petals;
  final _rng = Random(99);

  @override
  void initState() {
    super.initState();
    _petals = List.generate(4, (_) => _LotusPetal(_rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.animate) {
        _ctrl.repeat();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _FloatingLotusPetals oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _ctrl.repeat();
      } else {
        _ctrl.stop();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _LotusPetalPainter(
              petals: _petals,
              time: _ctrl.value,
            ),
          );
        },
      ),
    );
  }
}

class _LotusPetal {
  late double x, y, speed, rotSpeed, size, phase;

  _LotusPetal(Random rng) {
    x = rng.nextDouble();
    y = rng.nextDouble();
    speed = 0.015 + rng.nextDouble() * 0.03;
    rotSpeed = 0.5 + rng.nextDouble() * 1.5;
    size = 6 + rng.nextDouble() * 8;
    phase = rng.nextDouble() * 2 * pi;
  }
}

class _LotusPetalPainter extends CustomPainter {
  final List<_LotusPetal> petals;
  final double time;

  _LotusPetalPainter({required this.petals, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in petals) {
      final t = time * 2 * pi;

      // Drift downward with gentle side-to-side sway
      final py = (p.y + time * p.speed) % 1.2 - 0.1;
      final px = p.x + sin(t * 0.3 + p.phase) * 0.04;

      // Fade in/out at edges
      final fade = py < 0
          ? 0.0
          : py > 1
              ? 0.0
              : (py < 0.1 ? py / 0.1 : py > 0.9 ? (1 - py) / 0.1 : 1.0);

      if (fade <= 0) continue;

      canvas.save();
      canvas.translate(px * size.width, py * size.height);
      canvas.rotate(t * p.rotSpeed + p.phase);

      // Draw a petal shape (two quadratic beziers)
      final petalPath = Path();
      final s = p.size;
      petalPath.moveTo(0, -s);
      petalPath.quadraticBezierTo(s * 0.6, -s * 0.3, 0, s * 0.5);
      petalPath.quadraticBezierTo(-s * 0.6, -s * 0.3, 0, -s);
      petalPath.close();

      final paint = Paint()
        ..color = Color.fromRGBO(255, 200, 160, 0.08 * fade)
        ..style = PaintingStyle.fill;

      canvas.drawPath(petalPath, paint);

      // Subtle petal outline
      paint
        ..color = Color.fromRGBO(212, 175, 55, 0.12 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawPath(petalPath, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LotusPetalPainter old) => old.time != time;
}

// ═══════════════════════════════════════════════════════════════════════════
// GOD RAYS — Volumetric light rays emanating from behind the Om
// ═══════════════════════════════════════════════════════════════════════════

class _GodRays extends StatefulWidget {
  final bool animate;

  const _GodRays({this.animate = true});

  @override
  State<_GodRays> createState() => _GodRaysState();
}

class _GodRaysState extends State<_GodRays>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.animate) {
        _ctrl.repeat();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _GodRays oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _ctrl.repeat();
      } else {
        _ctrl.stop();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _GodRaysPainter(time: _ctrl.value),
          );
        },
      ),
    );
  }
}

class _GodRaysPainter extends CustomPainter {
  final double time;
  _GodRaysPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final t = time * 2 * pi;
    final maxRadius = size.width * 0.8;

    // Draw 6 light rays (reduced for performance)
    for (var i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * pi + t * 0.2;
      final rayOpacity = 0.025 + 0.015 * sin(t * 2 + i * 0.8);
      final rayWidth = 0.08 + 0.03 * sin(t + i * 1.2);

      final path = Path();
      path.moveTo(cx, cy);
      path.lineTo(
        cx + cos(angle - rayWidth) * maxRadius,
        cy + sin(angle - rayWidth) * maxRadius,
      );
      path.lineTo(
        cx + cos(angle + rayWidth) * maxRadius,
        cy + sin(angle + rayWidth) * maxRadius,
      );
      path.close();

      final paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, cy),
          maxRadius,
          [
            Color.fromRGBO(244, 228, 182, rayOpacity),
            const Color.fromRGBO(212, 175, 55, 0),
          ],
          [0.0, 1.0],
        );

      canvas.drawPath(path, paint);
    }

    // Central glow
    final glowIntensity = 0.08 + 0.04 * sin(t * 1.5);
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx, cy),
        80,
        [
          Color.fromRGBO(244, 228, 182, glowIntensity),
          const Color.fromRGBO(212, 175, 55, 0),
        ],
      );
    canvas.drawCircle(Offset(cx, cy), 80, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _GodRaysPainter old) => old.time != time;
}

// ═══════════════════════════════════════════════════════════════════════════
// ENERGY PULSE WAVES — Concentric rings expanding from center
// ═══════════════════════════════════════════════════════════════════════════

class _EnergyPulseWaves extends StatefulWidget {
  final bool animate;

  const _EnergyPulseWaves({this.animate = true});

  @override
  State<_EnergyPulseWaves> createState() => _EnergyPulseWavesState();
}

class _EnergyPulseWavesState extends State<_EnergyPulseWaves>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.animate) {
        _ctrl.repeat();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _EnergyPulseWaves oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _ctrl.repeat();
      } else {
        _ctrl.stop();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _EnergyPulsePainter(time: _ctrl.value),
          );
        },
      ),
    );
  }
}

class _EnergyPulsePainter extends CustomPainter {
  final double time;
  _EnergyPulsePainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.width * 0.5;

    // 3 staggered expanding rings
    for (var i = 0; i < 3; i++) {
      final phase = (time + i / 3.0) % 1.0;
      final radius = phase * maxR;
      final opacity = (1 - phase) * 0.07;

      if (opacity <= 0) continue;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * (1 - phase)
        ..color = Color.fromRGBO(212, 175, 55, opacity);

      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EnergyPulsePainter old) => old.time != time;
}

// ═══════════════════════════════════════════════════════════════════════════
// TOUCH RIPPLE LAYER — Sparkle burst on tap
// ═══════════════════════════════════════════════════════════════════════════

class _TouchRippleLayer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _TouchRippleLayer({required this.child, this.onTap});

  @override
  State<_TouchRippleLayer> createState() => _TouchRippleLayerState();
}

class _TouchRippleLayerState extends State<_TouchRippleLayer>
    with TickerProviderStateMixin {
  final List<_RippleData> _ripples = [];
  final List<Offset> _trailPoints = [];
  static const int _maxTrailPoints = 40;

  void _addRipple(Offset position) {
    widget.onTap?.call();
    HapticFeedback.lightImpact();
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    final ripple = _RippleData(
      position: position,
      controller: ctrl,
      sparkleCount: 8 + Random().nextInt(6),
      sparkleAngles: List.generate(14, (i) => Random().nextDouble() * 2 * pi),
      sparkleSpeeds: List.generate(14, (i) => 30.0 + Random().nextDouble() * 60),
    );
    setState(() => _ripples.add(ripple));
    ctrl.forward().then((_) {
      ctrl.dispose();
      if (mounted) setState(() => _ripples.remove(ripple));
    });
  }

  void _addTrailPoint(Offset position) {
    setState(() {
      _trailPoints.add(position);
      if (_trailPoints.length > _maxTrailPoints) _trailPoints.removeAt(0);
    });
  }

  void _clearTrail() {
    setState(() => _trailPoints.clear());
  }

  @override
  void dispose() {
    for (final r in _ripples) {
      r.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        _addRipple(e.localPosition);
        _clearTrail();
      },
      onPointerMove: (e) => _addTrailPoint(e.localPosition),
      onPointerUp: (_) => _clearTrail(),
      onPointerCancel: (_) => _clearTrail(),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) => _addRipple(details.localPosition),
        child: Stack(
          children: [
            widget.child,
            if (_trailPoints.length > 1)
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _LightningTrailPainter(points: _trailPoints),
                  ),
                ),
              ),
            if (_ripples.isNotEmpty)
              Positioned.fill(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: Listenable.merge(
                        _ripples.map((r) => r.controller).toList()),
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _TouchRipplePainter(ripples: _ripples),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LightningTrailPainter extends CustomPainter {
  final List<Offset> points;

  _LightningTrailPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    const coreColor = Color(0xFFE8D48A);
    const glowColor = Color(0xFFFFE066);
    final n = points.length;

    for (var i = 0; i < n - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final opacity = ((i + 1) / n).clamp(0.2, 1.0);
      final strokeWidth = 1.5 + (opacity * 2.5);
      final glowWidth = strokeWidth + 5;

      canvas.drawLine(
        p0,
        p1,
        Paint()
          ..color = glowColor.withValues(alpha: opacity * 0.4)
          ..strokeWidth = glowWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
      canvas.drawLine(
        p0,
        p1,
        Paint()
          ..color = coreColor.withValues(alpha: opacity * 0.95)
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LightningTrailPainter old) =>
      old.points.length != points.length;
}

class _RippleData {
  final Offset position;
  final AnimationController controller;
  final int sparkleCount;
  final List<double> sparkleAngles;
  final List<double> sparkleSpeeds;

  _RippleData({
    required this.position,
    required this.controller,
    required this.sparkleCount,
    required this.sparkleAngles,
    required this.sparkleSpeeds,
  });
}

class _TouchRipplePainter extends CustomPainter {
  final List<_RippleData> ripples;
  _TouchRipplePainter({required this.ripples});

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in ripples) {
      final t = r.controller.value;
      final pos = r.position;

      // Expanding ring
      final ringOpacity = (1 - t) * 0.3;
      if (ringOpacity > 0) {
        canvas.drawCircle(
          pos,
          t * 80,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 * (1 - t)
            ..color = Color.fromRGBO(244, 228, 182, ringOpacity),
        );
        // Second ring delayed
        if (t > 0.15) {
          final t2 = (t - 0.15) / 0.85;
          canvas.drawCircle(
            pos,
            t2 * 60,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5 * (1 - t2)
              ..color = Color.fromRGBO(212, 175, 55, (1 - t2) * 0.2),
          );
        }
      }

      // Sparkle particles bursting outward
      for (var i = 0; i < r.sparkleCount; i++) {
        final angle = r.sparkleAngles[i];
        final speed = r.sparkleSpeeds[i];
        final sparkleT = Curves.easeOut.transform(t);
        final sx = pos.dx + cos(angle) * speed * sparkleT;
        final sy = pos.dy + sin(angle) * speed * sparkleT;
        final sparkleOpacity = (1 - t) * 0.6;
        final sparkleSize = (1 - t) * 2.5;

        if (sparkleOpacity > 0) {
          canvas.drawCircle(
            Offset(sx, sy),
            sparkleSize,
            Paint()..color = Color.fromRGBO(244, 228, 182, sparkleOpacity),
          );

          // Tiny glow
          canvas.drawCircle(
            Offset(sx, sy),
            sparkleSize * 2,
            Paint()
              ..color = Color.fromRGBO(212, 175, 55, sparkleOpacity * 0.3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          );
        }
      }

      // Central flash
      if (t < 0.3) {
        final flashT = t / 0.3;
        canvas.drawCircle(
          pos,
          12 * (1 - flashT),
          Paint()
            ..color = Color.fromRGBO(255, 255, 240, (1 - flashT) * 0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TouchRipplePainter old) => true;
}

// ═══════════════════════════════════════════════════════════════════════════
