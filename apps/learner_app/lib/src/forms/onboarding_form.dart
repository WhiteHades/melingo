import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/fallback_strings.dart';
import '../l10n/language_packs.dart';
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
  bool _didSeedFromProfile = false;
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

    if (!_didSeedFromProfile && state.profile != null) {
      _nameController.text = state.profile!.displayName;
      _selectedLanguage = state.profile!.languageCode;
      _selectedLevel = state.profile!.level;
      _weeklyGoal = state.profile!.weeklyGoalMinutes.toDouble();
      _didSeedFromProfile = true;
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: FallbackStrings.onboardingDisplayNameLabel(context),
              hintText: FallbackStrings.onboardingDisplayNameHint(context),
            ),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return FallbackStrings.onboardingNameRequired(context);
              }
              if (value.trim().length < 2) {
                return FallbackStrings.onboardingNameTooShort(context);
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedLanguage,
            items: supportedLanguagePacks.map((LanguagePack pack) {
              return DropdownMenuItem<String>(
                value: pack.languageCode,
                child: Text(pack.displayName),
              );
            }).toList(growable: false),
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _selectedLanguage = value;
                });
              }
            },
            decoration: InputDecoration(
              labelText: FallbackStrings.onboardingTargetLanguage(context),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedLevel,
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
            decoration: InputDecoration(
              labelText: FallbackStrings.onboardingLevel(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${FallbackStrings.onboardingWeeklyGoalMinutes(context)}: ${_weeklyGoal.toInt()}',
          ),
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
                    final ScaffoldMessengerState messenger =
                        ScaffoldMessenger.of(context);
                    final String savedMessage =
                        FallbackStrings.onboardingSaved(context);
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
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(savedMessage),
                        ),
                      );
                    }
                  },
            child: Text(
              state.isSaving
                  ? FallbackStrings.onboardingSaving(context)
                  : FallbackStrings.onboardingSave(context),
            ),
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
            Text(FallbackStrings.onboardingNoProfileYet(context)),
          ],
        ],
      ),
    );
  }
}
