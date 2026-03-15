import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/journey_models.dart';
import '../providers/journey_providers.dart';

/// Dynamic setup flow from journey_types.setup_schema. On complete: start journey and navigate to Journey Home.
class JourneySetupScreen extends ConsumerStatefulWidget {
  final String slug;

  const JourneySetupScreen({super.key, required this.slug});

  @override
  ConsumerState<JourneySetupScreen> createState() => _JourneySetupScreenState();
}

class _JourneySetupScreenState extends ConsumerState<JourneySetupScreen> {
  final Map<String, dynamic> _answers = {};
  final Map<String, TextEditingController> _textControllers = {};
  int _currentStep = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<dynamic> _schemaList = [];

  bool _showQuestion(Map<String, dynamic> q) {
    final showIf = q['show_if'] as Map<String, dynamic>?;
    if (showIf == null) return true;
    final key = showIf['key'] as String?;
    final value = showIf['value'];
    if (key == null) return true;
    return _answers[key] == value;
  }

  List<Map<String, dynamic>> get _visibleQuestions {
    if (_schemaList.isEmpty) return [];
    final list = _schemaList
        .where((e) => e is Map<String, dynamic> && _showQuestion(e as Map<String, dynamic>))
        .map((e) => e as Map<String, dynamic>)
        .toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final typeAsync = ref.watch(journeyTypeBySlugProvider(widget.slug));
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('Start Journey'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: typeAsync.when(
        data: (journeyType) {
          if (journeyType == null) {
            return const Center(child: Text('Journey not found'));
          }
          _schemaList = journeyType.setupSchema ?? [];
          if (_visibleQuestions.isEmpty) {
            return _buildSubmitSection(context, journeyType);
          }
          return _buildForm(context, journeyType);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildForm(BuildContext context, JourneyType journeyType) {
    final visible = _visibleQuestions;
    if (_currentStep >= visible.length) {
      return _buildSubmitSection(context, journeyType);
    }
    final q = visible[_currentStep];
    final key = q['key'] as String? ?? '';
    final type = q['type'] ?? 'text';
    final typeStr = type is String ? type : 'text';
    final label = q['label'] as String? ?? key;
    final optional = q['optional'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            journeyType.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          if (journeyType.subtitle != null) Text(journeyType.subtitle!),
          const SizedBox(height: 24),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (typeStr == 'single_select') _buildSingleSelect(q, key),
          if (typeStr == 'date') _buildDateField(key),
          if (typeStr == 'text') _buildTextField(q, key, optional),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                TextButton(
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text('Back'),
                )
              else
                const SizedBox(),
              ElevatedButton(
                onPressed: () {
                  if (typeStr == 'text' && !optional && (_answers[key] == null || (_answers[key] as String).trim().isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill this field')));
                    return;
                  }
                  if (_currentStep < visible.length - 1) {
                    setState(() => _currentStep++);
                  } else {
                    _submit(context, journeyType);
                  }
                },
                child: Text(_currentStep < visible.length - 1 ? 'Next' : 'Start Journey'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSelect(Map<String, dynamic> q, String key) {
    final options = q['options'] as List<dynamic>? ?? [];
    final current = _answers[key];
    return Column(
      children: options.map((opt) {
        final optMap = opt is Map<String, dynamic> ? opt : {};
        final value = optMap['value'];
        final label = optMap['label'] as String? ?? value?.toString();
        final icon = optMap['icon'] as String?;
        final isSelected = current == value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: icon != null ? Text(icon, style: const TextStyle(fontSize: 24)) : null,
            title: Text(label ?? ''),
            selected: isSelected,
            onTap: () => setState(() => _answers[key] = value),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateField(String key) {
    final current = _answers[key] as String?;
    final date = current != null ? DateTime.tryParse(current) : null;
    return OutlinedButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          setState(() => _answers[key] = picked.toIso8601String().split('T').first);
        }
      },
      child: Text(date != null ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}' : 'Pick date'),
    );
  }

  Widget _buildTextField(Map<String, dynamic> q, String key, bool optional) {
    final initial = _answers[key] as String? ?? '';
    _textControllers[key] ??= TextEditingController(text: initial);
    return TextField(
      controller: _textControllers[key],
      decoration: InputDecoration(
        hintText: q['placeholder'] as String?,
        border: const OutlineInputBorder(),
      ),
      onChanged: (v) => setState(() => _answers[key] = v),
    );
  }

  Widget _buildSubmitSection(BuildContext context, JourneyType journeyType) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('You\'re all set to begin ${journeyType.title}.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          if (_isSubmitting)
            const CircularProgressIndicator()
          else
            ElevatedButton(
              onPressed: () => _submit(context, journeyType),
              child: const Text('Start Journey'),
            ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, JourneyType journeyType) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in')));
      return;
    }
    setState(() => _isSubmitting = true);
    final repo = ref.read(journeyRepositoryProvider);
    DateTime? startDate = DateTime.now();
    DateTime? targetDate;
    if (_answers['due_date'] != null) {
      targetDate = DateTime.tryParse(_answers['due_date'] as String);
    }
    if (_answers['child_dob'] != null) {
      final dob = DateTime.tryParse(_answers['child_dob'] as String);
      if (dob != null) startDate = dob;
    }
    final metadata = Map<String, dynamic>.from(_answers);
    if (metadata['due_date'] != null && metadata['pregnancy_due_date'] == null) {
      metadata['pregnancy_due_date'] = metadata['due_date'];
    }
    if (targetDate != null) metadata['mode'] = 'pregnant';
    else if (metadata['child_dob'] != null) metadata['mode'] = 'postnatal';
    else metadata['mode'] = 'planning';
    try {
      final userJourney = await repo.startJourney(
        userId: uid,
        journeyTypeId: journeyType.id,
        metadata: metadata,
        startDate: startDate,
        targetDate: targetDate,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (userJourney != null) {
        ref.invalidate(activeJourneyProvider);
        ref.invalidate(allUserJourneysProvider);
        Navigator.of(context).pushReplacementNamed(AppRouter.journeyHome, arguments: {'userJourneyId': userJourney.id});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not start journey')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
