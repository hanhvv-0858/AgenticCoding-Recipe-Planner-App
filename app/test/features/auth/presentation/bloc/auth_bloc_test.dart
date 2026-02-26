import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/auth/domain/entities/user.dart';
import 'package:recipe_planner/features/auth/domain/usecases/get_current_user.dart';
import 'package:recipe_planner/features/auth/domain/usecases/login.dart';
import 'package:recipe_planner/features/auth/domain/usecases/logout.dart';
import 'package:recipe_planner/features/auth/domain/usecases/register.dart';
import 'package:recipe_planner/features/auth/presentation/bloc/auth_bloc.dart';

// Mocks
class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockLogin extends Mock implements Login {}

class MockRegister extends Mock implements Register {}

class MockLogout extends Mock implements Logout {}

class FakeNoParams extends Fake implements NoParams {}

class FakeLoginParams extends Fake implements LoginParams {}

class FakeRegisterParams extends Fake implements RegisterParams {}

void main() {
  late AuthBloc authBloc;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockLogin mockLogin;
  late MockRegister mockRegister;
  late MockLogout mockLogout;

  const testUser = User(
    id: 'user-123',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeRegisterParams());
  });

  setUp(() {
    mockGetCurrentUser = MockGetCurrentUser();
    mockLogin = MockLogin();
    mockRegister = MockRegister();
    mockLogout = MockLogout();
    authBloc = AuthBloc(
      getCurrentUser: mockGetCurrentUser,
      login: mockLogin,
      register: mockRegister,
      logout: mockLogout,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, const AuthInitial());
    });

    group('CheckAuthStatus', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when user is authenticated',
        build: () {
          when(() => mockGetCurrentUser(any()))
              .thenAnswer((_) async => const Right(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const CheckAuthStatus()),
        expect: () => [
          const AuthLoading(),
          const Authenticated(user: testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when no user found',
        build: () {
          when(() => mockGetCurrentUser(any())).thenAnswer(
              (_) async => const Left(ServerFailure(message: 'Not auth')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const CheckAuthStatus()),
        expect: () => [
          const AuthLoading(),
          const Unauthenticated(),
        ],
      );
    });

    group('LoginSubmitted', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] on successful login',
        build: () {
          when(() => mockLogin(any()))
              .thenAnswer((_) async => const Right(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LoginSubmitted(
          email: 'test@example.com',
          password: 'password123',
        )),
        expect: () => [
          const AuthLoading(),
          const Authenticated(user: testUser),
        ],
        verify: (_) {
          verify(() => mockLogin(const LoginParams(
            email: 'test@example.com',
            password: 'password123',
          ))).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] on login failure',
        build: () {
          when(() => mockLogin(any())).thenAnswer((_) async =>
              const Left(
                  ServerFailure(message: 'Invalid email or password')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LoginSubmitted(
          email: 'test@example.com',
          password: 'wrong',
        )),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Invalid email or password'),
        ],
      );
    });

    group('RegisterSubmitted', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] on successful registration',
        build: () {
          when(() => mockRegister(any()))
              .thenAnswer((_) async => const Right(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const RegisterSubmitted(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        )),
        expect: () => [
          const AuthLoading(),
          const Authenticated(user: testUser),
        ],
        verify: (_) {
          verify(() => mockRegister(const RegisterParams(
            email: 'test@example.com',
            password: 'password123',
            displayName: 'Test User',
          ))).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] on registration failure',
        build: () {
          when(() => mockRegister(any())).thenAnswer((_) async =>
              const Left(ServerFailure(
                  message: 'An account with this email already exists')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const RegisterSubmitted(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        )),
        expect: () => [
          const AuthLoading(),
          const AuthError(
              message: 'An account with this email already exists'),
        ],
      );
    });

    group('LogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Unauthenticated] on logout',
        build: () {
          when(() => mockLogout(any()))
              .thenAnswer((_) async => const Right(null));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LogoutRequested()),
        expect: () => [
          const Unauthenticated(),
        ],
      );
    });

    group('ContinueAsGuest', () {
      blocTest<AuthBloc, AuthState>(
        'emits [GuestMode] when continuing as guest',
        build: () => authBloc,
        act: (bloc) => bloc.add(const ContinueAsGuest()),
        expect: () => [
          const GuestMode(),
        ],
      );
    });
  });
}
