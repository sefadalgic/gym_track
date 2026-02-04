import 'package:flutter/material.dart';
import 'package:gym_track/feature/exercices/view/exercises_view.dart';
import 'package:gym_track/feature/home/home_view.dart';
import 'package:gym_track/feature/profile/view/profile_view.dart';
import 'package:gym_track/feature/workouts/view/workouts_view.dart';

/// Main view with bottom navigation bar
class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  // List of pages for bottom navigation
  final List<Widget> _pages = const [
    HomeView(),
    WorkoutsView(),
    ExercisesView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          navigationBarTheme: NavigationBarThemeData(
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                  color: Color(0xFF00D9FF), // Cyan for selected
                );
              }
              return const IconThemeData(
                color: Color(0xFF8A8F98), // Gray for unselected
              );
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: Color(0xFF00D9FF), // Cyan for selected
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                );
              }
              return const TextStyle(
                color: Color(0xFF8A8F98), // Gray for unselected
                fontSize: 12,
                fontWeight: FontWeight.w500,
              );
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF151A21), // Dark surface color
          indicatorColor: const Color(0xFF00D9FF)
              .withValues(alpha: 0.2), // Cyan with transparency
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center),
              label: 'Workouts',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Exercises',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
