import 'package:flutter/material.dart';
import 'package:gym_track/feature/exercices/theme/exercises_theme.dart';
import 'package:gym_track/product/model/exercise_model.dart';

class ExerciseDetailView extends StatelessWidget {
  final ExerciseModel exercise;

  const ExerciseDetailView({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExercisesTheme.background,
      body: Stack(
        children: [
          // Scrollable Content
          CustomScrollView(
            slivers: [
              // Header Image
              _buildHeader(context),

              // Title & Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name ?? 'Exercise Detail',
                        style: ExercisesTheme.title.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Target: ${exercise.primaryMuscles?.map((e) => e.displayName).join(", ") ?? "General"}',
                        style:
                            ExercisesTheme.cardSubtitle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      _buildTags(),
                      const SizedBox(height: 32),
                      _buildSectionHeader('Your Statistics',
                          hasAction: true, actionText: 'View History'),
                      const SizedBox(height: 16),
                      _buildStatsRow(),
                      const SizedBox(height: 32),
                      _buildSectionHeader('How to perform'),
                      const SizedBox(height: 16),
                      _buildInstructionsList(),
                      const SizedBox(height: 120), // Bottom spacer for the FAB
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Action Button
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: _buildAddButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 350,
      backgroundColor: ExercisesTheme.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image with darker overlay
            Image.network(
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80', // Replace with exercise image
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    ExercisesTheme.background.withOpacity(0.8),
                    ExercisesTheme.background,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
            // Play Button Overlay
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: ExercisesTheme.accentGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ExercisesTheme.accentGreen.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.black, size: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags() {
    final tags = [
      exercise.primaryMuscles?.first.displayName ?? 'Body',
      exercise.equipment ?? 'Barbell',
      exercise.level ?? 'Advanced',
      exercise.category ?? 'Compound',
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: tags
          .map((tag) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: ExercisesTheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: ExercisesTheme.accentGreen.withOpacity(0.3)),
                ),
                child: Text(
                  tag,
                  style: ExercisesTheme.caption.copyWith(
                    color: ExercisesTheme.accentGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSectionHeader(String title,
      {bool hasAction = false, String? actionText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: ExercisesTheme.sectionTitle),
        if (hasAction)
          Text(
            actionText ?? '',
            style: const TextStyle(
              color: ExercisesTheme.accentGreen,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard(
                'BEST PR', '145', 'kg', Icons.emoji_events_outlined)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard(
                'VOLUME', '3.2k', 'kg', Icons.fitness_center_rounded)),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ExercisesTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: ExercisesTheme.surfaceHighlight.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ExercisesTheme.textSecondary, size: 18),
              const SizedBox(width: 8),
              Text(label, style: ExercisesTheme.statLabel),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: ExercisesTheme.statValue),
                const TextSpan(text: ' '),
                TextSpan(
                    text: unit,
                    style: ExercisesTheme.caption.copyWith(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsList() {
    final instructions = exercise.instructions ??
        [
          'Set the bar in the rack just below shoulder height. Step under the bar and place it across the back of your shoulders.',
          'Squeeze your shoulder blades together. Take a deep breath, brace your core, and lift the bar off the rack by straightening your legs.',
          'Bend your knees and hips simultaneously to lower your body. Keep your chest up and back straight. Go as deep as your mobility allows.',
          'Drive through your heels to return to the starting position. Exhale as you reach the top.',
        ];

    final titles = [
      'Setup the Bar',
      'Brace and Unrack',
      'The Descent',
      'Drive Up'
    ];

    return Column(
      children: List.generate(instructions.length, (index) {
        return _buildStepItem(
          index + 1,
          titles.length > index ? titles[index] : 'Step ${index + 1}',
          instructions[index],
          isLast: index == instructions.length - 1,
        );
      }),
    );
  }

  Widget _buildStepItem(int number, String title, String body,
      {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: ExercisesTheme.accentGreen, width: 2),
                ),
                child: Center(
                  child: Text('$number', style: ExercisesTheme.stepNumber),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: ExercisesTheme.surfaceHighlight,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: ExercisesTheme.cardTitle.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    style: ExercisesTheme.cardSubtitle.copyWith(
                        height: 1.5,
                        color: ExercisesTheme.textSecondary.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: ExercisesTheme.accentGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ExercisesTheme.accentGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.black, weight: 800),
            SizedBox(width: 12),
            Text(
              'Add to Workout',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
