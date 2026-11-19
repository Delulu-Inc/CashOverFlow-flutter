import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../core/network/api_client.dart';
import '../core/storage/session_storage.dart';
import '../features/ai_support/data/repositories/ai_support_repository.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/checkout/data/repositories/checkout_repository.dart';
import '../features/dashboard/data/repositories/dashboard_repository.dart';
import '../features/onboarding/data/repositories/onboarding_repository.dart';
import '../features/profile/data/repositories/profile_repository.dart';
import '../features/subscription/data/repositories/subscription_repository.dart';
import '../features/team/data/repositories/team_repository.dart';

/// Composition root: creates the data layer once and exposes it to the
/// widget tree through [RepositoryProvider]s.
class AppDependencies {
  AppDependencies._({
    required this.sessionStorage,
    required this.authRepository,
    required this.onboardingRepository,
    required this.checkoutRepository,
    required this.dashboardRepository,
    required this.aiSupportRepository,
    required this.teamRepository,
    required this.subscriptionRepository,
    required this.profileRepository,
  });

  /// [httpClient] can be replaced (e.g. by `MockClient` in tests).
  factory AppDependencies.create({http.Client? httpClient}) {
    final storage = SessionStorage();
    final api = ApiClient(storage: storage, httpClient: httpClient);

    return AppDependencies._(
      sessionStorage: storage,
      authRepository: AuthRepository(api: api, storage: storage),
      onboardingRepository: OnboardingRepository(api: api, storage: storage),
      checkoutRepository: CheckoutRepository(api: api),
      dashboardRepository: DashboardRepository(api: api),
      aiSupportRepository: AiSupportRepository(api: api),
      teamRepository: TeamRepository(api: api, storage: storage),
      subscriptionRepository: SubscriptionRepository(api: api),
      profileRepository: ProfileRepository(api: api, storage: storage),
    );
  }

  final SessionStorage sessionStorage;
  final AuthRepository authRepository;
  final OnboardingRepository onboardingRepository;
  final CheckoutRepository checkoutRepository;
  final DashboardRepository dashboardRepository;
  final AiSupportRepository aiSupportRepository;
  final TeamRepository teamRepository;
  final SubscriptionRepository subscriptionRepository;
  final ProfileRepository profileRepository;

  List<RepositoryProvider<Object>> get providers => [
    RepositoryProvider<SessionStorage>.value(value: sessionStorage),
    RepositoryProvider<AuthRepository>.value(value: authRepository),
    RepositoryProvider<OnboardingRepository>.value(value: onboardingRepository),
    RepositoryProvider<CheckoutRepository>.value(value: checkoutRepository),
    RepositoryProvider<DashboardRepository>.value(value: dashboardRepository),
    RepositoryProvider<AiSupportRepository>.value(value: aiSupportRepository),
    RepositoryProvider<TeamRepository>.value(value: teamRepository),
    RepositoryProvider<SubscriptionRepository>.value(
      value: subscriptionRepository,
    ),
    RepositoryProvider<ProfileRepository>.value(value: profileRepository),
  ];
}
