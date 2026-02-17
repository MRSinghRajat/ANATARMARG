import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SevaHelpScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const SevaHelpScreen({super.key, this.onComplete});

  @override
  State<SevaHelpScreen> createState() => _SevaHelpScreenState();
}

class _SevaHelpScreenState extends State<SevaHelpScreen> {
  String? _selectedCategory;
  final _journalController = TextEditingController();
  final _feelingController = TextEditingController();
  bool _completed = false;

  static const _categories = [
    _SevaCategory(
      name: 'Family',
      icon: Icons.home_outlined,
      color: Colors.pink,
      examples: [
        'Cook a meal for your family',
        'Help with household chores',
        'Spend quality time with elders',
      ],
    ),
    _SevaCategory(
      name: 'Community',
      icon: Icons.groups_outlined,
      color: Colors.blue,
      examples: [
        'Help a neighbour carry groceries',
        'Volunteer at a local event',
        'Teach someone a skill',
      ],
    ),
    _SevaCategory(
      name: 'Strangers',
      icon: Icons.emoji_people_outlined,
      color: Colors.orange,
      examples: [
        'Give directions to someone lost',
        'Hold the door open',
        'Offer your seat to someone',
      ],
    ),
    _SevaCategory(
      name: 'Animals',
      icon: Icons.pets_outlined,
      color: Colors.green,
      examples: [
        'Feed a stray animal',
        'Put out water for birds',
        'Rescue an injured animal',
      ],
    ),
    _SevaCategory(
      name: 'Nature',
      icon: Icons.eco_outlined,
      color: Colors.teal,
      examples: [
        'Plant a tree or sapling',
        'Clean up litter in your area',
        'Reduce waste today',
      ],
    ),
  ];

  @override
  void dispose() {
    _journalController.dispose();
    _feelingController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _journalController.text.trim().isNotEmpty && !_completed;

  void _submit() {
    if (!_canSubmit) return;
    setState(() => _completed = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: SafeArea(
        child: _completed ? _buildCompletion() : _buildMain(),
      ),
    );
  }

  Widget _buildMain() {
    return Column(
      children: [
        // App bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                'Seva — Help Someone',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // Dharmic intro
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.pink.withOpacity(0.15),
                        Colors.orange.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.pink.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'परोपकाराय पुण्याय',
                        style: GoogleFonts.notoSerifDevanagari(
                          color: Colors.pink.shade200,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '"Doing good to others is the highest merit"',
                        style: GoogleFonts.crimsonPro(
                          color: Colors.white70,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Seva (सेवा) is selfless service — the essence of Karma Yoga as taught in the Bhagavad Gita. '
                        'When we help without expecting reward, we purify the heart and dissolve the ego. '
                        'Lord Krishna says: "The wise work for the welfare of the world." (BG 3.25)',
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 12,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Category selection
                Text(
                  'Who did you help today?',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select a category for ideas, or go straight to journaling.',
                  style: GoogleFonts.poppins(
                      color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Category chips
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _categories.map((cat) {
                    final selected = _selectedCategory == cat.name;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedCategory =
                            selected ? null : cat.name;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? cat.color.withOpacity(0.2)
                              : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? cat.color.withOpacity(0.5)
                                : Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon,
                                color: selected
                                    ? cat.color
                                    : Colors.white54,
                                size: 18),
                            const SizedBox(width: 8),
                            Text(
                              cat.name,
                              style: GoogleFonts.poppins(
                                color: selected
                                    ? cat.color
                                    : Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Ideas for selected category
                if (_selectedCategory != null) ...[
                  const SizedBox(height: 16),
                  ..._categories
                      .firstWhere((c) => c.name == _selectedCategory)
                      .examples
                      .map((example) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  example,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )),
                ],

                const SizedBox(height: 24),

                // Journal entry
                Text(
                  'What did you do?',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _journalController,
                  maxLines: 6,
                  minLines: 4,
                  onChanged: (_) => setState(() {}),
                  style:
                      GoogleFonts.poppins(color: Colors.white, fontSize: 14, height: 1.5),
                  cursorColor: Colors.pink,
                  decoration: InputDecoration(
                    hintText: 'Describe how you helped someone today...',
                    hintStyle: GoogleFonts.poppins(
                        color: Colors.white30, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF1A1D23),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.pink.withValues(alpha: 0.5)),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 20),

                // Feelings
                Text(
                  'How did it make you feel?',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _feelingController,
                  maxLines: 4,
                  minLines: 2,
                  style:
                      GoogleFonts.poppins(color: Colors.white, fontSize: 14, height: 1.5),
                  cursorColor: Colors.pink,
                  decoration: InputDecoration(
                    hintText: 'Peaceful, happy, fulfilled...',
                    hintStyle: GoogleFonts.poppins(
                        color: Colors.white30, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF1A1D23),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.pink.withValues(alpha: 0.5)),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Submit button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                disabledBackgroundColor: Colors.pink.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Log My Seva',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletion() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.pink.withOpacity(0.3),
                  Colors.pink.withOpacity(0.05),
                ],
              ),
            ),
            child: const Icon(Icons.volunteer_activism,
                color: Colors.pink, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            'Thank You for Your Seva',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '"नरसेवा नारायणसेवा"\nService to humanity is service to God.',
            style: GoogleFonts.crimsonPro(
              color: Colors.pink.shade200,
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Every act of kindness, no matter how small, creates ripples of dharma in the world.',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Complete Task',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }
}

class _SevaCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> examples;

  const _SevaCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.examples,
  });
}
