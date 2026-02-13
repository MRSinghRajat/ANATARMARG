import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/custom_habit_model.dart';
import '../../data/services/custom_habit_service.dart';

/// Bottom sheet for adding or editing a custom habit
class AddHabitSheet extends StatefulWidget {
  final CustomHabit? editingHabit;
  final VoidCallback? onHabitAdded;

  const AddHabitSheet({
    super.key,
    this.editingHabit,
    this.onHabitAdded,
  });

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  HabitFrequency _frequency = HabitFrequency.daily;
  Set<int> _selectedDays = {1, 2, 3, 4, 5}; // Mon-Fri by default
  String _selectedIcon = 'check_circle';
  int? _targetStreak;
  bool _isLoading = false;

  final _habitService = CustomHabitService.instance;

  bool get isEditing => widget.editingHabit != null;

  @override
  void initState() {
    super.initState();
    if (widget.editingHabit != null) {
      _titleController.text = widget.editingHabit!.title;
      _descriptionController.text = widget.editingHabit!.description ?? '';
      _frequency = widget.editingHabit!.frequency;
      _selectedDays = Set.from(widget.editingHabit!.specificDays ?? [1, 2, 3, 4, 5]);
      _selectedIcon = widget.editingHabit!.iconName;
      _targetStreak = widget.editingHabit!.targetStreak;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Text(
                isEditing ? 'Edit Habit' : 'Create New Habit',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Habit name
              _buildTextField(
                controller: _titleController,
                label: 'Habit Name',
                hint: 'e.g., Drink 8 glasses of water',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description (optional)
              _buildTextField(
                controller: _descriptionController,
                label: 'Description (optional)',
                hint: 'Add more details about this habit',
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              
              // Icon selection
              _buildSectionLabel('Choose Icon'),
              const SizedBox(height: 8),
              _buildIconSelector(),
              const SizedBox(height: 20),
              
              // Frequency
              _buildSectionLabel('Frequency'),
              const SizedBox(height: 8),
              _buildFrequencySelector(),
              
              // Day selector (for specific days)
              if (_frequency == HabitFrequency.specificDays) ...[
                const SizedBox(height: 16),
                _buildDaySelector(),
              ],
              const SizedBox(height: 20),
              
              // Target streak (optional)
              _buildSectionLabel('Target Streak (optional)'),
              const SizedBox(height: 8),
              _buildTargetStreakSelector(),
              const SizedBox(height: 24),
              
              // Suggestions
              if (!isEditing) ...[
                _buildSectionLabel('Quick Add'),
                const SizedBox(height: 8),
                _buildSuggestions(),
                const SizedBox(height: 24),
              ],
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isEditing ? 'Save Changes' : 'Create Habit',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.white38),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryOrange),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        color: Colors.white70,
        fontSize: 13,
      ),
    );
  }

  Widget _buildIconSelector() {
    const icons = [
      'check_circle',
      'water_drop',
      'menu_book',
      'favorite',
      'accessibility_new',
      'phone_disabled',
      'directions_walk',
      'air',
      'lightbulb',
      'fitness_center',
      'bedtime',
      'restaurant',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: icons.map((iconName) {
        final isSelected = _selectedIcon == iconName;
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = iconName),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryOrange.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryOrange
                    : Colors.white.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              _getIconData(iconName),
              color: isSelected ? AppColors.primaryOrange : Colors.white54,
              size: 24,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFrequencySelector() {
    return Row(
      children: HabitFrequency.values.map((freq) {
        final isSelected = _frequency == freq;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _frequency = freq),
            child: Container(
              margin: EdgeInsets.only(
                right: freq != HabitFrequency.values.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryOrange.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryOrange
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                freq.displayName,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: isSelected ? AppColors.primaryOrange : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaySelector() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isSelected = _selectedDays.contains(index);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(index);
              } else {
                _selectedDays.add(index);
              }
            });
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryOrange.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryOrange
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Center(
              child: Text(
                days[index],
                style: GoogleFonts.poppins(
                  color: isSelected ? AppColors.primaryOrange : Colors.white54,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTargetStreakSelector() {
    final streaks = [null, 7, 21, 30, 66, 100];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: streaks.map((streak) {
        final isSelected = _targetStreak == streak;
        return GestureDetector(
          onTap: () => setState(() => _targetStreak = streak),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryOrange.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryOrange
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Text(
              streak == null ? 'None' : '$streak days',
              style: GoogleFonts.poppins(
                color: isSelected ? AppColors.primaryOrange : Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = _habitService.habitSuggestions.take(4).toList();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((suggestion) {
        return GestureDetector(
          onTap: () {
            _titleController.text = suggestion.title;
            _descriptionController.text = suggestion.description;
            _selectedIcon = suggestion.iconName;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconData(suggestion.iconName),
                  size: 14,
                  color: Colors.white54,
                ),
                const SizedBox(width: 6),
                Text(
                  suggestion.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'water_drop':
        return Icons.water_drop;
      case 'menu_book':
        return Icons.menu_book;
      case 'favorite':
        return Icons.favorite;
      case 'accessibility_new':
        return Icons.accessibility_new;
      case 'phone_disabled':
        return Icons.phone_disabled;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'air':
        return Icons.air;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'bedtime':
        return Icons.bedtime;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.check_circle;
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (isEditing) {
        await _habitService.updateHabit(
          widget.editingHabit!.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            iconName: _selectedIcon,
            frequency: _frequency,
            specificDays: _frequency == HabitFrequency.specificDays
                ? _selectedDays.toList()
                : null,
            targetStreak: _targetStreak,
          ),
        );
      } else {
        await _habitService.createHabit(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          iconName: _selectedIcon,
          frequency: _frequency,
          specificDays: _frequency == HabitFrequency.specificDays
              ? _selectedDays.toList()
              : null,
          targetStreak: _targetStreak,
        );
      }

      widget.onHabitAdded?.call();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save habit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
