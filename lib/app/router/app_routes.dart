/// Every URL the app understands.
abstract final class AppRoutes {
  // Public
  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String registrationSuccess = '/register/success';

  // Invitation & checkout flow
  static const String acceptInvite = '/accept-invite';
  static const String setPassword = '/set-password';
  static const String paymentSuccess = '/payment-success';
  static const String paymentFailed = '/payment-failed';
  static const String paymentCancel = '/payment-cancel';

  // Admin
  static const String adminDashboard = '/admin-dashboard';

  // Dashboard shell (sidebar pages)
  static const String dashboard = '/dashboard';
  static const String aiSupport = '/ai-support';
  static const String teamManagement = '/team-management';
  static const String subscription = '/subscription';
  static const String profileSettings = '/profile-settings';
}
