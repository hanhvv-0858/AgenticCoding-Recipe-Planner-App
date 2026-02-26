import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_planner/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:recipe_planner/features/auth/presentation/pages/register_page.dart';

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
        child: const RegisterPage(),
      ),
    );
  }

  group('RegisterPage', () {
    testWidgets('renders all form fields', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Display Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders create account button', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.widgetWithText(ElevatedButton, 'Create Account'),
          findsOneWidget);
    });

    testWidgets('renders sign in link', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows validation error for empty display name',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Display name is required'), findsOneWidget);
    });

    testWidgets('shows validation error for empty email',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      // Fill display name only
      await tester.enterText(
          find.byType(TextFormField).first, 'Test User');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(
          find.byType(TextFormField).first, 'Test User');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'bad-email');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows validation error for short password',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(
          find.byType(TextFormField).first, 'Test User');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(
          find.byType(TextFormField).last, 'short');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(
          find.text('Password must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('triggers RegisterSubmitted on valid form',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(
          find.byType(TextFormField).first, 'Test User');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(
          find.byType(TextFormField).last, 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      verify(() => mockAuthBloc.add(const RegisterSubmitted(
            email: 'test@example.com',
            password: 'password123',
            displayName: 'Test User',
          ))).called(1);
    });

    testWidgets('shows error message when AuthError state',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(
          const AuthError(message: 'An account with this email already exists'));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('An account with this email already exists'),
          findsOneWidget);
    });

    testWidgets('shows loading indicator when AuthLoading',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('disables button when loading',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
