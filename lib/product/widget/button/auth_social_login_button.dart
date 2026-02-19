import 'package:flutter/material.dart';
import 'package:gym_track/core/thene/app_theme.dart';
import 'package:gym_track/feature/login/theme/login_theme.dart';

class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton(
      {super.key,
      required this.onPressed,
      required this.icon,
      required this.label});

  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.background.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.secondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: LoginTheme.inputText.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
