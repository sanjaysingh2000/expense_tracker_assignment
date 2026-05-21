
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EmptyExpensesState extends StatelessWidget {
  const EmptyExpensesState({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F0F172A),
                blurRadius: 30,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFCCFBF1), Color(0xFFE0F2FE)],
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 38,
                  color: Color(0xFF0F766E),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'No expenses yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Start with your first entry and turn this into a polished spending log for the assignment.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), height: 1.6),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create First Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

