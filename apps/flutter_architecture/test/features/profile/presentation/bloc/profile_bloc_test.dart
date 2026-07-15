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
                state.errorMessage == null,
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
                  state.errorMessage == null,
            ),
          ],
        ),
      );

      expect(profileRepository.getProfileCallCount, 1);
    });
  });
}

class _FakeProfileRepository implements ProfileRepository {
  int getProfileCallCount = 0;

  @override
  Future<Result<Profile>> getProfile() async {
    getProfileCallCount += 1;
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
