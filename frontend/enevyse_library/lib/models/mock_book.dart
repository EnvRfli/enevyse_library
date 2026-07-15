import 'package:flutter/material.dart';

class MockBook {
  final String id;
  final String title;
  final String author;
  final double rating;
  final int availableCount; // 0 = unavailable
  final Color placeholderColor; // Since we use colors instead of images for now
  
  // Extra fields for Book Detail
  final String genre;
  final String publisher;
  final String year;
  final String isbn;
  final String language;
  final int pages;
  final String shelf;
  final String description;

  MockBook({
    required this.id,
    required this.title,
    required this.author,
    required this.rating,
    required this.availableCount,
    required this.placeholderColor,
    this.genre = 'General',
    this.publisher = 'Unknown',
    this.year = '2023',
    this.isbn = '000-0000000000',
    this.language = 'English',
    this.pages = 200,
    this.shelf = 'A1',
    this.description = 'No description available for this book.',
  });
}

final List<MockBook> mockTrendingBooks = [
  MockBook(
    id: '1',
    title: 'Atomic Habits',
    author: 'James Clear',
    rating: 4.9,
    availableCount: 6,
    placeholderColor: const Color(0xFF9E86E1), // Purple
    genre: 'Self Development',
    publisher: 'Avery',
    year: '2018',
    isbn: '978-0735211292',
    language: 'English',
    pages: 320,
    shelf: 'B2 · Row 14',
    description: 'A practical, easy-to-apply guide to building good habits and breaking bad ones, using small changes that compound into remarkable results.',
  ),
  MockBook(
    id: '2',
    title: 'Deep Work',
    author: 'Cal Newport',
    rating: 4.6,
    availableCount: 3,
    placeholderColor: const Color(0xFF63B8D9), // Blue
  ),
  MockBook(
    id: '3',
    title: 'Sapiens',
    author: 'Y. N. Harari',
    rating: 4.8,
    availableCount: 2,
    placeholderColor: const Color(0xFFEAA270), // Orange
  ),
];

final List<MockBook> mockRecommendedBooks = [
  MockBook(
    id: '4',
    title: 'The Psychology of Money',
    author: 'Morgan Housel',
    rating: 4.7,
    availableCount: 1,
    placeholderColor: const Color(0xFF75D9A5), // Green
  ),
  MockBook(
    id: '5',
    title: 'Thinking, Fast and Slow',
    author: 'Daniel Kahneman',
    rating: 4.5,
    availableCount: 0, // Not available
    placeholderColor: const Color(0xFFE892A8), // Pink
  ),
  MockBook(
    id: '6',
    title: 'Essentialism',
    author: 'Greg McKeown',
    rating: 4.8,
    availableCount: 10,
    placeholderColor: const Color(0xFF8B9CEB), // Soft Indigo
  ),
];

final List<MockBook> mockNewArrivals = [
  MockBook(
    id: '7',
    title: 'Outlive',
    author: 'Peter Attia',
    rating: 4.9,
    availableCount: 5,
    placeholderColor: const Color(0xFF63B8D9), // Blue
  ),
  MockBook(
    id: '8',
    title: 'Tomorrow, and Tomorrow...',
    author: 'G. Zevin',
    rating: 4.8,
    availableCount: 2,
    placeholderColor: const Color(0xFF9E86E1), // Purple
  ),
];
