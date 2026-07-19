import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/features/profile/domain/entities/profile.dart';
import 'package:flutter_architecture/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_architecture/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:flutter_architecture/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileBloc', () {
    test('未登入時不呼叫 GetProfileUseCase，並顯示未登入狀態', () async {
      final profileRepository = _FakeProfileRepository();
      final authRepository = _FakeAuthRepository();
      final sessionManager = SessionManager();
      final bloc = ProfileBloc(
        GetProfileUseCase(profileRepository),
        LogoutUseCase(authRepository),
        sessionManager,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      bloc.add(const ProfileEvent.requested());

      await expectLater(
        bloc.stream,
        emits(
          predicate<ProfileState>(
            (state) =>
                !state.isLoading &&
                !state.isAuthenticated &&
                state.profile == null &&
                state.failure == null && state.failureOperation == null,
          ),
        ),
      );

      expect(profileRepository.getProfileCallCount, 0);
    });

    test('已登入時呼叫 GetProfileUseCase，並顯示目前登入用戶', () async {
      final profileRepository = _FakeProfileRepository();
      final authRepository = _FakeAuthRepository();
      final sessionManager = SessionManager();
      final bloc = ProfileBloc(
        GetProfileUseCase(profileRepository),
        LogoutUseCase(authRepository),
        sessionManager,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      sessionManager.setAuthenticated(
        accessToken: 'access-token',
        userId: 'user-1',
      );

      bloc.add(const ProfileEvent.requested());

      await expectLater(
        bloc.stream,
        emitsInOrder(
          <Matcher>[
            predicate<ProfileState>(
              (state) => state.isLoading && state.isAuthenticated,
            ),
            predicate<ProfileState>(
              (state) =>
                  !state.isLoading &&
                  state.isAuthenticated &&
                  state.profile?.name == 'Demo User' &&
                  state.failure == null && state.failureOperation == null,
            ),
          ],
        ),
      );

      expect(profileRepository.getProfileCallCount, 1);
    });

    test('Profile unknown error 保留 framework error flow，不降級為 Failure', () async {
      final unknownError = StateError('profile unknown');
      final profileRepository = _FakeProfileRepository(error: unknownError);
      final authRepository = _FakeAuthRepository();
      final sessionManager = SessionManager();
      late ProfileBloc bloc;
      final errors = <Object>[];
      final errorCaptured = Completer<void>();

      sessionManager.setAuthenticated(
        accessToken: 'access-token',
        userId: 'user-1',
      );

      await runZonedGuarded(() async {
        bloc = ProfileBloc(
          GetProfileUseCase(profileRepository),
          LogoutUseCase(authRepository),
          sessionManager,
        );
        bloc.add(const ProfileEvent.requested());
        await errorCaptured.future.timeout(const Duration(seconds: 1));
      }, (error, stackTrace) {
        errors.add(error);
        if (!errorCaptured.isCompleted) errorCaptured.complete();
      });

      expect(errors, contains(same(unknownError)));
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.failure, isNull);
      expect(bloc.state.failureOperation, isNull);

      await bloc.close();
      await sessionManager.dispose();
    });

    test('Session expiration 會同步清除 Profile UI state', () async {
      final profileRepository = _FakeProfileRepository();
      final authRepository = _FakeAuthRepository();
      final sessionManager = SessionManager();
      final bloc = ProfileBloc(
        GetProfileUseCase(profileRepository),
        LogoutUseCase(authRepository),
        sessionManager,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      sessionManager.setAuthenticated(
        accessToken: 'access-token',
        userId: 'user-1',
      );
      bloc.add(const ProfileEvent.requested());

      final states = <ProfileState>[];
      final subscription = bloc.stream.listen(states.add);
      addTearDown(subscription.cancel);

      await bloc.stream.firstWhere(
        (state) => !state.isLoading && state.profile?.name == 'Demo User',
      );
      sessionManager.clear();

      final expired = await bloc.stream.firstWhere(
        (state) => !state.isLoading && !state.isAuthenticated,
      );
      expect(expired.profile, isNull);
      expect(expired.failure, isNull);
      expect(expired.failureOperation, isNull);
      expect(states.any((state) => state.isAuthenticated), isTrue);
    });

    test('Session expiration 後舊 Profile response 不會恢復已登入 UI', () async {
      final response = Completer<Result<Profile>>();
      final profileRepository = _FakeProfileRepository(response: response);
      final authRepository = _FakeAuthRepository();
      final sessionManager = SessionManager();
      final bloc = ProfileBloc(
        GetProfileUseCase(profileRepository),
        LogoutUseCase(authRepository),
        sessionManager,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      sessionManager.setAuthenticated(
        accessToken: 'access-token',
        userId: 'user-1',
      );
      bloc.add(const ProfileEvent.requested());
      await bloc.stream.firstWhere((state) => state.isLoading);

      sessionManager.clear();
      await bloc.stream.firstWhere((state) => !state.isAuthenticated);

      response.complete(
        const Success(Profile(id: 'user-1', name: 'Account A')),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.isAuthenticated, isFalse);
      expect(bloc.state.profile, isNull);
    });

    test('帳號切換後舊 Profile response 不會覆蓋新 Session UI', () async {
      final response = Completer<Result<Profile>>();
      final profileRepository = _FakeProfileRepository(response: response);
      final authRepository = _FakeAuthRepository();
      final sessionManager = SessionManager();
      final bloc = ProfileBloc(
        GetProfileUseCase(profileRepository),
        LogoutUseCase(authRepository),
        sessionManager,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      sessionManager.setAuthenticated(
        accessToken: 'account-a-token',
        userId: 'account-a',
      );
      bloc.add(const ProfileEvent.requested());
      await bloc.stream.firstWhere((state) => state.isLoading);

      sessionManager.clear();
      await bloc.stream.firstWhere((state) => !state.isAuthenticated);
      sessionManager.setAuthenticated(
        accessToken: 'account-b-token',
        userId: 'account-b',
      );
      final stateBeforeOldResponse = bloc.state;

      response.complete(
        const Success(Profile(id: 'account-a', name: 'Account A')),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, stateBeforeOldResponse);
      expect(sessionManager.currentSession?.userId, 'account-b');
    });

    test('clear 後立即重新登入時舊 sessionCleared event 不會清除新 Session UI',
        () async {
      final profileRepository = _FakeProfileRepository();
      final authRepository = _FakeAuthRepository();
      final sessionManager = SessionManager();
      final bloc = ProfileBloc(
        GetProfileUseCase(profileRepository),
        LogoutUseCase(authRepository),
        sessionManager,
      );
      addTearDown(bloc.close);
      addTearDown(sessionManager.dispose);

      sessionManager.setAuthenticated(
        accessToken: 'account-a-token',
        userId: 'account-a',
      );
      bloc.add(const ProfileEvent.requested());
      await bloc.stream.firstWhere(
        (state) => !state.isLoading && state.profile != null,
      );

      sessionManager.clear();
      sessionManager.setAuthenticated(
        accessToken: 'account-b-token',
        userId: 'account-b',
      );
      await bloc.stream.firstWhere(
        (state) =>
            !state.isLoading &&
            state.isAuthenticated &&
            state.profile?.name == 'Demo User',
      );

      expect(sessionManager.currentSession?.userId, 'account-b');
      expect(bloc.state.isAuthenticated, isTrue);
      expect(bloc.state.profile?.name, 'Demo User');
      expect(profileRepository.getProfileCallCount, 2);
    });
  });
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.response, this.error});

  final Completer<Result<Profile>>? response;
  final Object? error;
  int getProfileCallCount = 0;

  @override
  Future<Result<Profile>> getProfile() async {
    getProfileCallCount += 1;
    final configuredError = error;
    if (configuredError != null) {
      throw configuredError;
    }
    final pending = response;
    if (pending != null) {
      return pending.future;
    }
    return const Success(
      Profile(
        id: 'user-1',
        name: 'Demo User',
      ),
    );
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<AuthResult>> login({
    required String account,
    required String password,
  }) async {
    return const Success(
      AuthResult(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        user: AuthUser(
          id: 'user-1',
          name: 'Demo User',
        ),
      ),
    );
  }

  @override
  Future<Result<void>> logout() async {
    return const Success(null);
  }

  @override
  Future<Result<AuthUser?>> restoreSession() async {
    return const Success(null);
  }
}
