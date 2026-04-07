import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../onboarding/onboarding_controller.dart';
import '../onboarding/onboarding_profile.dart';

class OnboardingForm extends ConsumerStatefulWidget {
  const OnboardingForm({super.key});

  @override
  ConsumerState<OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends ConsumerState<OnboardingForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String _selectedLanguage = 'de';
  String _selectedLevel = 'a1';
  double _weeklyGoal = 60;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingState state = ref.watch(onboardingControllerProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'display name',
              hintText: 'enter your name',
            ),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'name is required';
              }
              if (value.trim().length < 2) {
                return 'name must be at least 2 chars';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem(value: 'de', child: Text('german')),
              DropdownMenuItem(value: 'ar', child: Text('arabic')),
            ],
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _selectedLanguage = value;
                });
              }
            },
            decoration: const InputDecoration(labelText: 'target language'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedLevel,
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem(value: 'a1', child: Text('a1')),
              DropdownMenuItem(value: 'a2', child: Text('a2')),
              DropdownMenuItem(value: 'b1', child: Text('b1')),
            ],
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _selectedLevel = value;
                });
              }
            },
            decoration: const InputDecoration(labelText: 'level'),
          ),
          const SizedBox(height: 12),
          Text('weekly goal minutes: ${_weeklyGoal.toInt()}'),
          Slider(
            min: 30,
            max: 300,
            divisions: 27,
            value: _weeklyGoal,
            label: _weeklyGoal.toInt().toString(),
            onChanged: (double value) {
              setState(() {
                _weeklyGoal = value;
              });
            },
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: state.isSaving
                ? null
                : () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final OnboardingProfile profile = OnboardingProfile(
                        displayName: _nameController.text.trim(),
                        languageCode: _selectedLanguage,
                        level: _selectedLevel,
                        weeklyGoalMinutes: _weeklyGoal.toInt(),
                      );
                      await ref
                          .read(onboardingControllerProvider.notifier)
                          .save(profile);
                      if (!mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'onboarding saved locally and queued for sync',
                          ),
                        ),
                      );
                    }
                  },
            child: Text(state.isSaving ? 'saving...' : 'save onboarding'),
          ),
          if (state.saveError != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              state.saveError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (state.profile != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'saved profile: ${state.profile!.displayName} (${state.profile!.languageCode}, ${state.profile!.level}, ${state.profile!.weeklyGoalMinutes}m)',
            ),
          ],
          if (state.profile == null) ...<Widget>[
            const SizedBox(height: 8),
            const Text('no saved onboarding profile yet'),
          ],
        ],
      ),
    );
  }
}
