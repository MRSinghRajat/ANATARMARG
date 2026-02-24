import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_clock.dart';

class ManifestationPracticeScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const ManifestationPracticeScreen({super.key, this.onComplete});

  @override
  State<ManifestationPracticeScreen> createState() =>
      _ManifestationPracticeScreenState();
}

class _ManifestationPracticeScreenState
    extends State<ManifestationPracticeScreen> {
  final _goalController = TextEditingController();
  static const String _prefKeyPrefix = 'manifestation_';

  static const List<String> _suggestions = [
    'Health',
    'Relationships',
    'Career',
    'Peace of mind',
    'Service',
    'Growth',
    'Abundance',
    'Creativity',
    'Spiritual progress',
  ];

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _saveAndComplete() async {
    final text = _goalController.text.trim();
    if (text.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = '$_prefKeyPrefix${AppClock.now().year}_${AppClock.now().month}_${AppClock.now().day}';
      await prefs.setString(dateKey, text);
    } catch (_) {}

    widget.onComplete?.call();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manifestation',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Manifestation is the practice of focusing your thoughts and intentions on what you want to create in your life. By writing it down clearly, you align your energy with your goals.',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'What do you want to achieve?',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _goalController,
                maxLines: 4,
                minLines: 3,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
                cursorColor: Colors.amber,
                decoration: InputDecoration(
                  hintText: 'Write your intention clearly...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A1D23),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.amber.withValues(alpha: 0.5),
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Suggestions',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestions.map((s) {
                  return ActionChip(
                    label: Text(
                      s,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    backgroundColor: const Color(0xFF1A1D23),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    onPressed: () {
                      final current = _goalController.text.trim();
                      _goalController.text = current.isEmpty
                          ? s
                          : '$current, $s';
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _goalController.text.trim().isEmpty
                      ? null
                      : _saveAndComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "I've set my intention",
                    style: GoogleFonts.poppins(
                      color: _goalController.text.trim().isEmpty
                          ? Colors.white38
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
