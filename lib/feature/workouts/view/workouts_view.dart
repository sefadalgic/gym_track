import 'package:flutter/material.dart';

/// Workouts view page for creating weekly workout plans
class WorkoutsView extends StatefulWidget {
  const WorkoutsView({super.key});

  @override
  State<WorkoutsView> createState() => _WorkoutsViewState();
}

class _WorkoutsViewState extends State<WorkoutsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Plan', icon: Icon(Icons.calendar_today)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyPlanTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _createWeeklyPlan(context),
              icon: const Icon(Icons.add),
              label: const Text('New Plan'),
            )
          : null,
    );
  }

  /// My Plan tab - shows weekly workout plan
  Widget _buildMyPlanTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildWeeklyPlanHeader(context),
        const SizedBox(height: 16),
        _buildWeeklyPlanCard(context),
        const SizedBox(height: 24),
        Text(
          'Workout Days',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildWorkoutDayCard(
          context,
          'Monday',
          'Push Day',
          '8 exercises',
          Icons.fitness_center,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildWorkoutDayCard(
          context,
          'Wednesday',
          'Pull Day',
          '7 exercises',
          Icons.accessibility_new,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildWorkoutDayCard(
          context,
          'Friday',
          'Leg Day',
          '6 exercises',
          Icons.directions_run,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildAddWorkoutDayCard(context),
      ],
    );
  }

  Widget _buildWeeklyPlanHeader(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Week Plan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Week 1 - January 2026',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editWeeklyPlan(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyPlanCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPlanStat(
                  context,
                  Icons.calendar_today,
                  'Training Days',
                  '3 days/week',
                ),
                _buildPlanStat(
                  context,
                  Icons.fitness_center,
                  'Total Exercises',
                  '21 exercises',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanStat(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWorkoutDayCard(
    BuildContext context,
    String day,
    String workoutName,
    String exerciseCount,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: InkWell(
        onTap: () => _showWorkoutDetails(context, day, workoutName),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workoutName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exerciseCount,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editWorkoutDay(context, day, workoutName),
                tooltip: 'Edit workout',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddWorkoutDayCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _addWorkoutDay(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Add Workout Day',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// History tab - shows past workouts
  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHistoryCard(
          context,
          'Push Day',
          'Today, 10:30 AM',
          '45 min',
          '12 sets',
          true,
        ),
        const SizedBox(height: 12),
        _buildHistoryCard(
          context,
          'Leg Day',
          'Yesterday, 6:00 PM',
          '60 min',
          '15 sets',
          false,
        ),
        const SizedBox(height: 12),
        _buildHistoryCard(
          context,
          'Pull Day',
          'Jan 15, 2026',
          '50 min',
          '14 sets',
          false,
        ),
      ],
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    String workoutName,
    String date,
    String duration,
    String sets,
    bool isRecent,
  ) {
    return Card(
      child: InkWell(
        onTap: () => _showHistoryDetails(context, workoutName),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    workoutName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (isRecent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Recent',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildHistoryStat(context, Icons.timer, duration),
                  const SizedBox(width: 24),
                  _buildHistoryStat(context, Icons.fitness_center, sets),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryStat(BuildContext context, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  void _createWeeklyPlan(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _WeeklyPlanDialog(),
    );
  }

  void _editWeeklyPlan(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _WeeklyPlanDialog(),
    );
  }

  void _addWorkoutDay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddWorkoutDayDialog(),
    );
  }

  void _editWorkoutDay(BuildContext context, String day, String workoutName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _WorkoutDetailPage(
          day: day,
          workoutName: workoutName,
        ),
      ),
    );
  }

  void _showWorkoutDetails(
      BuildContext context, String day, String workoutName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _WorkoutDetailPage(
          day: day,
          workoutName: workoutName,
        ),
      ),
    );
  }

  void _showHistoryDetails(BuildContext context, String workoutName) {
    _showSnackBar(context, 'History details for $workoutName coming soon...');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Dialog for creating/editing weekly plan
class _WeeklyPlanDialog extends StatefulWidget {
  @override
  State<_WeeklyPlanDialog> createState() => _WeeklyPlanDialogState();
}

class _WeeklyPlanDialogState extends State<_WeeklyPlanDialog> {
  int _trainingDays = 3;
  String _selectedSplit = 'Push/Pull/Legs';

  // Workout split options with their recommended days
  final Map<String, Map<String, dynamic>> _splitOptions = {
    'Push/Pull/Legs': {
      'days': [3, 6],
      'description': 'Push, Pull, Legs rotation',
      'icon': Icons.fitness_center,
      'color': Colors.blue,
    },
    'Upper/Lower': {
      'days': [4, 6],
      'description': 'Upper body and lower body split',
      'icon': Icons.accessibility_new,
      'color': Colors.green,
    },
    'Full Body': {
      'days': [3, 4, 5],
      'description': 'Full body workouts each session',
      'icon': Icons.person,
      'color': Colors.orange,
    },
    'Bro Split': {
      'days': [5, 6],
      'description': 'One muscle group per day',
      'icon': Icons.sports_gymnastics,
      'color': Colors.purple,
    },
    'Custom': {
      'days': [1, 2, 3, 4, 5, 6, 7],
      'description': 'Create your own split',
      'icon': Icons.edit,
      'color': Colors.teal,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Antrenman Planı Oluştur',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Training Days Section
                Text(
                  'Haftada Kaç Gün Antrenman Yapacaksınız?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: _trainingDays > 1
                          ? () => setState(() => _trainingDays--)
                          : null,
                      iconSize: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$_trainingDays',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          Text(
                            'gün/hafta',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: _trainingDays < 7
                          ? () => setState(() => _trainingDays++)
                          : null,
                      iconSize: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Split Selection Section
                Text(
                  'Antrenman Programı Türü',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Split Options
                ..._splitOptions.entries.map((entry) {
                  final splitName = entry.key;
                  final splitData = entry.value;
                  final isRecommended =
                      (splitData['days'] as List<int>).contains(_trainingDays);
                  final isSelected = _selectedSplit == splitName;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => setState(() => _selectedSplit = splitName),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withOpacity(0.5)
                              : null,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: (splitData['color'] as Color)
                                  .withOpacity(0.2),
                              child: Icon(
                                splitData['icon'] as IconData,
                                color: splitData['color'] as Color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        splitName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      if (isRecommended) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.green.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Önerilen',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    splitData['description'] as String,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Plan oluşturuldu: $_selectedSplit - $_trainingDays gün/hafta',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Planı Oluştur'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog for adding a workout day
class _AddWorkoutDayDialog extends StatefulWidget {
  @override
  State<_AddWorkoutDayDialog> createState() => _AddWorkoutDayDialogState();
}

class _AddWorkoutDayDialogState extends State<_AddWorkoutDayDialog> {
  String _selectedDay = 'Monday';
  final _workoutNameController = TextEditingController();

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void dispose() {
    _workoutNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Workout Day'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedDay,
            decoration: const InputDecoration(
              labelText: 'Day of Week',
              border: OutlineInputBorder(),
            ),
            items: _days.map((day) {
              return DropdownMenuItem(
                value: day,
                child: Text(day),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedDay = value!);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _workoutNameController,
            decoration: const InputDecoration(
              labelText: 'Workout Name',
              hintText: 'e.g., Push Day, Leg Day',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_workoutNameController.text.isNotEmpty) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _WorkoutDetailPage(
                    day: _selectedDay,
                    workoutName: _workoutNameController.text,
                  ),
                ),
              );
            }
          },
          child: const Text('Next'),
        ),
      ],
    );
  }
}

/// Workout detail page for adding exercises and sets
class _WorkoutDetailPage extends StatefulWidget {
  final String day;
  final String workoutName;

  const _WorkoutDetailPage({
    required this.day,
    required this.workoutName,
  });

  @override
  State<_WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<_WorkoutDetailPage> {
  final List<Map<String, dynamic>> _exercises = [
    {'name': 'Bench Press', 'sets': 4, 'reps': '8-10'},
    {'name': 'Incline Dumbbell Press', 'sets': 3, 'reps': '10-12'},
    {'name': 'Cable Flyes', 'sets': 3, 'reps': '12-15'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.workoutName),
            Text(
              widget.day,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveWorkout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Exercises',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${_exercises.length}',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Sets',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${_exercises.fold(0, (sum, ex) => sum + (ex['sets'] as int))}',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Exercises',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ..._exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildExerciseCard(context, index, exercise),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _addExercise(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
      BuildContext context, int index, Map<String, dynamic> exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise['name'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeExercise(index),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sets',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: exercise['sets'] > 1
                                ? () => _updateSets(index, exercise['sets'] - 1)
                                : null,
                            iconSize: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${exercise['sets']}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () =>
                                _updateSets(index, exercise['sets'] + 1),
                            iconSize: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reps',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'e.g., 8-10',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        controller:
                            TextEditingController(text: exercise['reps']),
                        onChanged: (value) => _updateReps(index, value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateSets(int index, int newSets) {
    setState(() {
      _exercises[index]['sets'] = newSets;
    });
  }

  void _updateReps(int index, String newReps) {
    setState(() {
      _exercises[index]['reps'] = newReps;
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _addExercise(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Exercise'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Exercise Name',
              hintText: 'e.g., Bench Press',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _exercises.add({
                      'name': controller.text,
                      'sets': 3,
                      'reps': '8-12',
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveWorkout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Workout saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
}
