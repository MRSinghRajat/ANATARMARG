import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import '../../core/utils/rive_helper.dart';

/// Rive-powered room background for Aangan and Ashram.
/// Displays the room architecture with character layered on top.
class RiveRoomBackground extends StatefulWidget {
  final BoxFit fit;

  const RiveRoomBackground({
    super.key,
    this.fit = BoxFit.cover,
  });

  @override
  State<RiveRoomBackground> createState() => _RiveRoomBackgroundState();
}

class _RiveRoomBackgroundState extends State<RiveRoomBackground> {
  Artboard? _artboard;
  bool _isLoaded = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  Future<void> _loadRoom() async {
    try {
      final file = await RiveFile.asset(RiveHelper.roomRiveFilePath);
      final artboard = file.mainArtboard;

      // Play default animation if available
      if (artboard.animations.isNotEmpty) {
        artboard.addController(SimpleAnimation(artboard.animations.first.name));
      }

      if (mounted) {
        setState(() {
          _artboard = artboard;
          _isLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString();
          _isLoaded = false;
        });
      }
      debugPrint('RiveRoomBackground: Load failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return _buildFallbackBackground();
    }
    if (!_isLoaded || _artboard == null) {
      return _buildFallbackBackground();
    }
    return SizedBox.expand(
      child: Rive(
        artboard: _artboard!,
        fit: widget.fit,
        antialiasing: true,
      ),
    );
  }

  Widget _buildFallbackBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade100.withOpacity(0.3),
            Colors.brown.shade100.withOpacity(0.5),
          ],
        ),
      ),
    );
  }
}
