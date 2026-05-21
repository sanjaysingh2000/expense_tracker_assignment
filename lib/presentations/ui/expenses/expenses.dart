import 'package:assignment_01/presentations/controller/expenses_controller.dart';
import 'package:assignment_01/presentations/ui/expenses_summary/summary_expense.dart';
import 'package:assignment_01/presentations/ui/expenses/widgets/animated_category_selector.dart';
import 'package:assignment_01/presentations/ui/expenses/widgets/expense_card.dart';
import 'package:assignment_01/presentations/ui/expenses/widgets/expenses_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/expense.dart';

class ExpensesScreen extends StatelessWidget {
  ExpensesScreen({super.key});

  final ExpenseController controller = Get.put(ExpenseController());

  static const List<String> _currencies = ['INR', 'USD', 'EUR'];
  static const List<String> _categories = ['Food', 'Travel', 'Shopping'];

  Future<void> _showExpenseSheet(
    BuildContext context, {
    Expense? expense,
  }) async {
    final isEditing = expense != null;
    final titleController = TextEditingController(text: expense?.title ?? '');
    final amountController = TextEditingController(
      text: expense != null ? expense.amount.toStringAsFixed(2) : '',
    );
    String selectedCurrency = expense?.currency ?? _currencies.first;
    String selectedCategory = expense?.category ?? _categories.first;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 56,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7E1E8),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: const Color(0x33FFFFFF),
                                child: Icon(
                                  isEditing
                                      ? Icons.edit_note_rounded
                                      : Icons.receipt_long_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isEditing
                                          ? 'Edit Expense'
                                          : 'Add New Expense',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      isEditing
                                          ? 'Update the details and keep your tracker accurate.'
                                          : 'Log spending with clean details and keep the tracker sharp.',
                                      style: const TextStyle(
                                        color: Color(0xD9FFFFFF),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: titleController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Expense title',
                            hintText: 'Dinner, cab ride, headphones...',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            hintText: 'Enter amount',
                            prefixIcon: Icon(Icons.currency_rupee_rounded),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Currency',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _currencies.map((currency) {
                            final isSelected = selectedCurrency == currency;
                            return ChoiceChip(
                              label: Text(currency),
                              selected: isSelected,
                              onSelected: (_) {
                                setModalState(() {
                                  selectedCurrency = currency;
                                });
                              },
                              selectedColor: const Color(0xFFCCFBF1),
                              backgroundColor: const Color(0xFFF1F5F9),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF0F766E)
                                    : const Color(0xFF334155),
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedCategorySelector(
                          categories: _categories,
                          selectedCategory: selectedCategory,
                          onCategorySelected: (category) {
                            setModalState(() {
                              selectedCategory = category;
                            });
                          },
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final title = titleController.text.trim();
                              final amount = double.tryParse(
                                amountController.text.trim(),
                              );

                              if (title.isEmpty ||
                                  amount == null ||
                                  amount <= 0) {
                                Get.snackbar(
                                  'Invalid expense',
                                  'Please enter a title and a valid amount.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFF0F172A),
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(16),
                                );
                                return;
                              }

                              final updatedExpense = Expense(
                                id:
                                    expense?.id ??
                                    DateTime.now().toIso8601String(),
                                title: title,
                                amount: amount,
                                currency: selectedCurrency,
                                category: selectedCategory,
                                date: expense?.date ?? DateTime.now(),
                                isSynced: expense?.isSynced ?? false,
                              );

                              if (isEditing) {
                                await controller.updateExpense(updatedExpense);
                              } else {
                                await controller.addExpense(updatedExpense);
                              }

                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(
                              isEditing ? 'Update Expense' : 'Save Expense',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => const SummaryScreen()),
                    icon: const Icon(Icons.insights_rounded),
                    label: const Text('Summary'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F766E),
                      side: const BorderSide(color: Color(0x260F766E)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showExpenseSheet(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        final expenses = controller.expenses;
        final categoryCount = expenses
            .map((expense) => expense.category)
            .toSet()
            .length;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _ExpensesHeader(
                totalEntries: expenses.length,
                categoryCount: categoryCount,
                isOnline: controller.isOnline.value,
                isSyncing: controller.isSyncing.value,
                onOpenSummary: () => Get.to(() => const SummaryScreen()),
                onSync: controller.syncPendingActions,
              ),
            ),
            if (expenses.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyExpensesState(
                  onAddPressed: () => _showExpenseSheet(context),
                ),
              )
            else ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 14),
                  child: Row(
                    children: [
                      Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final expense = expenses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: ExpenseCard(
                        expense: expense,
                        onEdit: () =>
                            _showExpenseSheet(context, expense: expense),
                        onDelete: () => controller.deleteExpense(expense.id),
                        onKeepLocal: () =>
                            controller.resolveConflictWithLocal(expense.id),
                        onUseRemote: () =>
                            controller.resolveConflictWithRemote(expense.id),
                      ),
                    );
                  }, childCount: expenses.length),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _ExpensesHeader extends StatelessWidget {
  const _ExpensesHeader({
    required this.totalEntries,
    required this.categoryCount,
    required this.isOnline,
    required this.isSyncing,
    required this.onOpenSummary,
    required this.onSync,
  });

  final int totalEntries;
  final int categoryCount;
  final bool isOnline;
  final bool isSyncing;
  final VoidCallback onOpenSummary;
  final Future<void> Function() onSync;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF134E4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expense Tracker',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Track spending with a cleaner view and faster decision-making.',
                        style: TextStyle(
                          color: Color(0xCCFFFFFF),
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _HeaderMetricCard(
                    label: 'Entries',
                    value: '$totalEntries',
                    icon: Icons.receipt_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HeaderMetricCard(
                    label: 'Categories',
                    value: '$categoryCount',
                    icon: Icons.grid_view_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderMetricCard extends StatelessWidget {
  const _HeaderMetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xC7FFFFFF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
