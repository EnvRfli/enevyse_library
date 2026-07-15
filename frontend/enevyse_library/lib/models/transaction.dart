import 'book.dart';

class Transaction {
  final String id;
  final String borrowId;
  final String userId;
  final String bookId;
  final String status;
  final String pickupLocation;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
  final DateTime? pickedUpAt;
  final DateTime? returnedAt;
  
  // Optional populated book
  final Book? book;

  Transaction({
    required this.id,
    required this.borrowId,
    required this.userId,
    required this.bookId,
    required this.status,
    required this.pickupLocation,
    required this.borrowDate,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
    this.pickedUpAt,
    this.returnedAt,
    this.book,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      borrowId: json['borrow_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      bookId: json['book_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      pickupLocation: json['pickup_location']?.toString() ?? '',
      borrowDate: json['borrow_date'] != null ? DateTime.parse(json['borrow_date']) : DateTime.now(),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : DateTime.now().add(const Duration(days: 7)),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at']) : null,
      pickedUpAt: json['picked_up_at'] != null ? DateTime.parse(json['picked_up_at']) : null,
      returnedAt: json['returned_at'] != null ? DateTime.parse(json['returned_at']) : null,
      book: json['book'] != null ? Book.fromJson(json['book']) : null,
    );
  }
}
