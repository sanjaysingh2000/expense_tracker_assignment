import 'package:flutter/material.dart';

Color expenseCategoryColor(String category) {
  switch (category) {
    case 'Food':
      return const Color(0xFFEA580C);
    case 'Travel':
      return const Color(0xFF0284C7);
    case 'Shopping':
      return const Color(0xFF7C3AED);
    default:
      return const Color(0xFF0F766E);
  }
}

IconData expenseCategoryIcon(String category) {
  switch (category) {
    case 'Food':
      return Icons.restaurant_rounded;
    case 'Travel':
      return Icons.flight_takeoff_rounded;
    case 'Shopping':
      return Icons.shopping_bag_rounded;
    default:
      return Icons.payments_rounded;
  }
}

String expenseCurrencySymbol(String currency) {
  switch (currency) {
    case 'USD':
      return '\$';
    case 'EUR':
      return 'EUR ';
    case 'INR':
    default:
      return 'Rs ';
  }
}

String formatExpenseDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
