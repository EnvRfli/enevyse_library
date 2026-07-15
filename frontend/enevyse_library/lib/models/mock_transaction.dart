import 'mock_book.dart';

enum TransactionStatus {
  pending,
  approved,
  pickedUp,
  returned,
  overdue,
  rejected,
}

class MockTransaction {
  final String id;
  final MockBook book;
  final DateTime borrowDate;
  final DateTime dueDate;
  final String pickupLocation;
  final TransactionStatus status;

  // Timeline dates
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final DateTime? pickedUpAt;
  final DateTime? returnedAt;

  MockTransaction({
    required this.id,
    required this.book,
    required this.borrowDate,
    required this.dueDate,
    required this.pickupLocation,
    required this.status,
    this.createdAt,
    this.approvedAt,
    this.pickedUpAt,
    this.returnedAt,
  });

  // Helper to calculate days left
  int get daysLeft {
    final now = DateTime.now();
    // Ignore time for accurate day count
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }
}

// Dummy data for testing UI without API
final List<MockTransaction> mockTransactions = [
  MockTransaction(
    id: 'LB-20260714-118',
    book: mockTrendingBooks[0], // Atomic Habits
    borrowDate: DateTime.now().subtract(const Duration(days: 4)),
    dueDate: DateTime.now().add(const Duration(days: 3)),
    pickupLocation: 'Main Library — Front Desk',
    status: TransactionStatus.pickedUp,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    approvedAt: DateTime.now().subtract(const Duration(days: 4, hours: 22)),
    pickedUpAt: DateTime.now().subtract(const Duration(days: 4, hours: 20)),
    returnedAt: null,
  ),
  MockTransaction(
    id: 'LB-20260708-092',
    book: mockRecommendedBooks[
        0], // The Psychology of Money (Assuming ID 2 in real app)
    borrowDate: DateTime.now().subtract(const Duration(days: 2)),
    dueDate: DateTime.now().add(const Duration(days: 10)),
    pickupLocation: 'North Wing — Lockers',
    status: TransactionStatus.pickedUp,
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    approvedAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
    pickedUpAt: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
    returnedAt: null,
  ),
];

final List<MockTransaction> mockHistoryTransactions = [
  MockTransaction(
    id: 'LB-20260601-042',
    book: mockTrendingBooks[1], // Another book
    borrowDate: DateTime.now().subtract(const Duration(days: 40)),
    dueDate: DateTime.now().subtract(const Duration(days: 26)),
    pickupLocation: 'South Branch',
    status: TransactionStatus.returned,
    createdAt: DateTime.now().subtract(const Duration(days: 40, hours: 5)),
    approvedAt: DateTime.now().subtract(const Duration(days: 40, hours: 4)),
    pickedUpAt: DateTime.now().subtract(const Duration(days: 40, hours: 1)),
    returnedAt: DateTime.now().subtract(const Duration(days: 28)),
  ),
];
