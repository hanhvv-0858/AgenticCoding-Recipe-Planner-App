import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_planner/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:recipe_planner/features/auth/presentation/pages/login_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginPage(),
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('renders email and password fields',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders sign in button', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('renders create account link', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('renders continue as guest option',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('shows validation error for empty email',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(
          find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows validation error for empty password',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows validation error for short password',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'short');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(
          find.text('Password must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('triggers LoginSubmitted event on valid submit',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(
          find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      verify(() => mockAuthBloc.add(const LoginSubmitted(
            email: 'test@example.com',
            password: 'password123',
          ))).called(1);
    });

    testWidgets('shows error message when AuthError state',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state)
          .thenReturn(const AuthError(message: 'Invalid email or password'));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Invalid email or password'), findsOneWidget);
    });

    testWidgets('shows loading indicator when AuthLoading',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('disables sign in button when loading',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('triggers ContinueAsGuest on guest button tap',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      verify(() => mockAuthBloc.add(const ContinueAsGuest())).called(1);
    });
  });
}
