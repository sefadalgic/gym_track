import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_track/core/constants/navigation/navigation_constants.dart';
import 'package:gym_track/product/service/auth_service.dart';

/// Profile view - Matches design reference exactly
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  static const Color _background = Color(0xFF0D0D0D);
  static const Color _card = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFE8622A);
  static const Color _orangeLight = Color(0xFFF07040);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFF8A8F98);

  int _selectedStatIndex = 1; // "BESTS" selected by default
  User? _currentUser;

  final List<Map<String, dynamic>> _stats = [
    {'icon': Icons.fitness_center, 'value': '124', 'label': 'WORKOUTS'},
    {'icon': Icons.emoji_events, 'value': '12', 'label': 'BESTS'},
    {'icon': Icons.local_fire_department, 'value': '15', 'label': 'STREAK'},
  ];

  final List<Map<String, dynamic>> _settingsItems = [
    {
      'icon': Icons.person_outline,
      'title': 'Personal Information',
      'subtitle': 'Height, weight, age',
    },
    {
      'icon': Icons.track_changes_outlined,
      'title': 'Fitness Goals',
      'subtitle': 'Set weekly targets',
    },
    {
      'icon': Icons.watch_outlined,
      'title': 'Connected Devices',
      'subtitle': 'Sync your wearables',
    },
    {
      'icon': Icons.shield_outlined,
      'title': 'Privacy Settings',
      'subtitle': 'Manage your visibility',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = AuthService.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: _textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildEditProfileButton(),
            const SizedBox(height: 28),
            _buildStatsRow(),
            const SizedBox(height: 32),
            _buildAccountSettings(),
            const SizedBox(height: 16),
            _buildLogoutButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Avatar with orange ring and level badge
        Stack(
          alignment: Alignment.center,
          children: [
            // Orange ring
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _orange, width: 3),
              ),
            ),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF2A1A0A),
              child: _currentUser?.photoURL != null
                  ? ClipOval(
                      child: Image.network(
                        _currentUser!.photoURL!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 52,
                      color: _orange.withValues(alpha: 0.7),
                    ),
            ),
            // Level badge
            Positioned(
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LEVEL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '42',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Name
        Text(
          _currentUser?.displayName ?? 'Username',
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        // Title
        Text(
          'ELITE ATHLETE',
          style: TextStyle(
            color: _orange,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: _orange.withValues(alpha: 0.6), width: 1.5),
            backgroundColor: _orange.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Edit Profile',
            style: TextStyle(
              color: _orangeLight,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_stats.length, (index) {
          final isSelected = _selectedStatIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedStatIndex = index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border(
                          bottom: BorderSide(color: _orange, width: 3),
                        )
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _stats[index]['icon'] as IconData,
                      color: isSelected ? _orange : _textSecondary,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _stats[index]['value'] as String,
                      style: TextStyle(
                        color: isSelected ? _orange : _textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _stats[index]['label'] as String,
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'ACCOUNT SETTINGS',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          ..._settingsItems.map((item) => _buildSettingsItem(item)),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            item['icon'] as IconData,
            color: _orange,
            size: 20,
          ),
        ),
        title: Text(
          item['title'] as String,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          item['subtitle'] as String,
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: _textSecondary.withValues(alpha: 0.5),
        ),
        onTap: () {
          if (item['title'] == 'Personal Information') {
            context.push(NavigationConstants.personalInformation);
          }
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.logout,
              color: Colors.red,
              size: 20,
            ),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: _showLogoutDialog,
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        title: const Text('Log Out', style: TextStyle(color: _textPrimary)),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: _textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.instance.signOut();
              if (context.mounted) {
                context.go(NavigationConstants.login);
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
