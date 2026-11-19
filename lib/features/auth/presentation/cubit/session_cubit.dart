import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_logger.dart';
import '../../data/models/current_user.dart';
import '../../data/repositories/auth_repository.dart';

enum SessionStatus {
  /// Nothing has been loaded yet.
  unknown,

  /// `GET /me` is in flight.
  loading,

  /// A token exists and the user profile was loaded.
  authenticated,

  /// No token stored on the device.
  guest,

  /// A token exists but the profile could not be loaded.
  failed,
}

class SessionState {
  const SessionState({
    this.status = SessionStatus.unknown,
    this.user,
    this.cachedRole,
  });

  final SessionStatus status;
  final CurrentUser? user;

  /// Role cached from a previous session, available before `/me` returns.
  final String? cachedRole;

  bool get isResolving =>
      status == SessionStatus.unknown || status == SessionStatus.loading;

  String? get role => user?.displayRole ?? cachedRole;

  /// Whether the user may open owner-only pages.
  ///
  /// Returns `null` while the role is still unknown. When the role cannot be
  /// determined at all, access is granted and the API enforces permissions
  /// (same behavior as before the refactor).
  bool? get canAccessOwnerPages {
    final currentRole = role;
    if (currentRole != null) return currentRole.trim().toLowerCase() == 'owner';
    return isResolving ? null : true;
  }
}

/// App-wide session state shared by the sidebar, route guards and pages.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._authRepository) : super(const SessionState());

  final AuthRepository _authRepository;

  /// Loads the current user once (pass [force] to refresh it).
  Future<void> load({bool force = false}) async {
    if (!force &&
        (state.status == SessionStatus.loading ||
            state.status == SessionStatus.authenticated)) {
      return;
    }

    if (!await _authRepository.hasSession) {
      emit(const SessionState(status: SessionStatus.guest));
      return;
    }

    final cachedRole = await _authRepository.cachedRole;
    emit(
      SessionState(
        status: SessionStatus.loading,
        user: state.user,
        cachedRole: cachedRole,
      ),
    );

    try {
      final user = await _authRepository.fetchCurrentUser();
      emit(SessionState(status: SessionStatus.authenticated, user: user));
    } catch (error) {
      AppLogger.error('Failed to load the current user', error);
      emit(SessionState(status: SessionStatus.failed, cachedRole: cachedRole));
    }
  }

  /// Called right after a successful login.
  void signedIn(CurrentUser? user) {
    emit(
      user == null
          ? const SessionState()
          : SessionState(status: SessionStatus.authenticated, user: user),
    );
  }

  Future<void> signOut() async {
    await _authRepository.logout();
    emit(const SessionState(status: SessionStatus.guest));
  }
}
