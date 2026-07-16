import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/main_layout/main_layout.dart';
import '../screens/book_detail/book_detail_screen.dart';
import '../screens/admin/add_book_screen.dart';
import '../screens/admin/edit_book_screen.dart';
import '../screens/admin/edit_book_form_screen.dart';
import '../screens/admin/approve_book_screen.dart';
import '../screens/borrow/borrow_form_screen.dart';
import '../screens/borrow/borrow_success_screen.dart';
import '../screens/borrow_detail/borrow_detail_screen.dart';
import '../screens/profile/favorite_books_screen.dart';
import '../screens/profile/update_profile_screen.dart';
import '../screens/home/book_list_screen.dart';
import '../models/book.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
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
        path: '/admin/approve-book',
        builder: (context, state) => const ApproveBookScreen(),
      ),
      GoRoute(
        path: '/borrow-success',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BorrowSuccessScreen(
            borrowId: extra['borrowId'] as String? ?? '',
            bookTitle: extra['bookTitle'] as String? ?? '',
            deadline: extra['deadline'] as DateTime? ?? DateTime.now(),
            isFromBorrowing: extra['isFromBorrowing'] as bool? ?? false,
            status: extra['status'] as String? ?? '',
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
      GoRoute(
        path: '/admin/add-book',
        builder: (context, state) => const AddBookScreen(),
      ),
      GoRoute(
        path: '/admin/edit-book',
        builder: (context, state) => const EditBookScreen(),
      ),
      GoRoute(
        path: '/admin/edit-book/form/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditBookFormScreen(bookId: id);
        },
      ),
      GoRoute(
        path: '/profile/favorites',
        builder: (context, state) => const FavoriteBooksScreen(),
      ),
      GoRoute(
        path: '/update-profile',
        builder: (context, state) => const UpdateProfileScreen(),
      ),
      GoRoute(
        path: '/book-list',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BookListScreen(
            title: extra['title'] as String? ?? 'Books',
            books: (extra['books'] as List<dynamic>?)?.cast<Book>() ?? [],
          );
        },
      ),
    ],
  );
}
