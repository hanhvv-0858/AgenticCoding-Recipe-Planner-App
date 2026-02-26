import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recipe_planner/features/home/domain/entities/cooking_step.dart';

/// Full-screen cooking mode — step-by-step with large text and navigation.
class CookingModePage extends StatefulWidget {
  final String recipeTitle;
  final List<CookingStep> steps;

  const CookingModePage({
    super.key,
    required this.recipeTitle,
    required this.steps,
  });

  @override
  State<CookingModePage> createState() => _CookingModePageState();
}

class _CookingModePageState extends State<CookingModePage> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Keep screen awake during cooking mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.recipeTitle)),
        body: const Center(child: Text('No steps available')),
      );
    }

    final step = widget.steps[_currentStep];
    final totalSteps = widget.steps.length;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.recipeTitle),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Step ${_currentStep + 1} of $totalSteps',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / totalSteps,
            ),

            // Step content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Step number
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${step.stepNumber}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Instruction text (large)
                        Text(
                          step.instruction,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentStep > 0
                          ? () => setState(() => _currentStep--)
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _currentStep < totalSteps - 1
                        ? FilledButton.icon(
                            onPressed: () =>
                                setState(() => _currentStep++),
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next'),
                          )
                        : FilledButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.check),
                            label: const Text('Done'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
