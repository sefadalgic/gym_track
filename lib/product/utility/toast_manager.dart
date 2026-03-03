import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_track/feature/login/theme/login_theme.dart';

/// Centralized manager for showing toast-style notifications.
@immutable
final class ToastManager {
  const ToastManager._();

  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, LoginTheme.success);
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, LoginTheme.error);
  }

  /// Maps [FirebaseAuthException] codes to user-friendly messages and shows an error toast.
  static void showFirebaseError(BuildContext context, FirebaseAuthException e) {
    final message = switch (e.code) {
      'invalid-email' => 'Geçersiz e-posta adresi formatı.',
      'user-disabled' => 'Bu kullanıcı hesabı devre dışı bırakılmış.',
      'user-not-found' =>
        'Bu e-posta adresiyle kayıtlı bir kullanıcı bulunamadı.',
      'wrong-password' => 'Hatalı şifre girdiniz.',
      'too-many-requests' =>
        'Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin.',
      'operation-not-allowed' => 'E-posta/şifre girişi etkin değil.',
      'network-request-failed' =>
        'Ağ bağlantısı hatası. Lütfen internetinizi kontrol edin.',
      'invalid-credential' =>
        'Kimlik doğrulama başarısız. Lütfen bilgilerinizi kontrol edin.',
      _ => 'Bir hata oluştu: ${e.message ?? e.code}',
    };
    showError(context, message);
  }

  static void _showToast(
      BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}
