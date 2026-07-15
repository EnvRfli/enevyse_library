import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main_layout/main_layout.dart';
import '../screens/book_detail/book_detail_screen.dart';
import '../screens/borrow/borrow_form_screen.dart';
import '../screens/borrow/borrow_success_screen.dart';
import '../screens/borrow_detail/borrow_detail_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainLayout(),
      ),
      GoRoute(
        path: '/book/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BookDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/borrow/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BorrowFormScreen(bookId: id);
        },
      ),
      GoRoute(
        path: '/borrow-success',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return BorrowSuccessScreen(
            transactionId: extras['transactionId'] as String,
            bookTitle: extras['bookTitle'] as String,
            deadline: extras['deadline'] as DateTime,
          );
        },
      ),
      GoRoute(
        path: '/borrow-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BorrowDetailScreen(transactionId: id);
        },
      ),
    ],
  );
}
