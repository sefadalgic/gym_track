import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:gym_track/core/thene/app_theme.dart';
import 'package:gym_track/feature/workouts/view/create_workout_flow.dart';

class EmptyWorkoutPlanView extends StatelessWidget {
  const EmptyWorkoutPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildDashedWorkoutArea(),
                    const SizedBox(height: 48),
                    _buildTextSection(),
                    const SizedBox(height: 40),
                    _buildActionButtons(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {},
          ),
          const Text(
            'Antrenman Planı',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.calendar_month_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDashedWorkoutArea() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dashed Box
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
            ),
            child: CustomPaint(
              painter: _DashedRectPainter(
                color: const Color(0xFF2C3542),
                strokeWidth: 2,
                gap: 6,
              ),
            ),
          ),
          // Main Calendar Icon (Center)
          Positioned.fill(
            child: Center(
              child: Icon(
                Icons.calendar_today_outlined,
                size: 80,
                color: const Color(0xFF2C3542),
              ),
            ),
          ),
          // Calendar 'X' indicator
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Icon(
                  Icons.close,
                  size: 30,
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
          ),
          // Dumbbell Icon (Top Left)
          Positioned(
            top: -10,
            left: -10,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          // Plus Icon (Bottom Right)
          Positioned(
            bottom: -20,
            right: -20,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD447), // Yellow from UI
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD447).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection() {
    return Column(
      children: [
        const Text(
          'Henüz Bir Planın Yok',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Gelişimini takip etmek ve hedeflerine ulaşmak için hemen bir antrenman programı oluştur veya hazır planlardan birini seç.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateWorkoutFlow(),
                  fullscreenDialog: true,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.calendar_today),
            label: const Text(
              'Plan Oluştur',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E252E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.explore_outlined),
            label: const Text(
              'Hazır Planlara Göz At',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(24),
      ));

    final dashPath = Path();
    double distance = 0.0;
    for (final PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
      distance = 0.0;
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
