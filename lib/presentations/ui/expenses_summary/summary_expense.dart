import 'package:assignment_01/data/models/expense.dart';
import 'package:assignment_01/presentations/controller/expenses_controller.dart';
import 'package:assignment_01/presentations/utils/expense_ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final ExpenseController controller = Get.find<ExpenseController>();

  @override
  void initState() {
    super.initState();
    Future.microtask(controller.calculateTotal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final expenses = controller.expenses;
        final categoryCounts = _buildCategoryCounts(expenses);
        final topCategory = categoryCounts.isEmpty
            ? null
            : categoryCounts.entries.reduce(
                (current, next) => current.value >= next.value ? current : next,
              );
        final mostRecentExpense = expenses.isEmpty ? null : expenses.first;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _SummaryHeader(
                totalInINR: controller.totalInINR.value,
                isLoading: controller.isCalculatingTotal.value,
                onRefresh: controller.calculateTotal,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Expanded(
                        child: _InsightCard(
                          label: 'Transactions',
                          value: '${expenses.length}',
                          subtitle: 'Recorded entries',
                          icon: Icons.receipt_long_rounded,
                          tint: const Color(0xFFE0F2FE),
                          iconColor: const Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InsightCard(
                          label: 'Top Category',
                          value: topCategory?.key ?? 'None',
                          subtitle: topCategory == null
                              ? 'Add expense data'
                              : '${topCategory.value} item${topCategory.value == 1 ? '' : 's'}',
                          icon: Icons.auto_awesome_mosaic_rounded,
                          tint: const Color(0xFFFEF3C7),
                          iconColor: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _RecentHighlightCard(expense: mostRecentExpense),
                  const SizedBox(height: 22),
                  const Text(
                    'Category Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A quick view of where most entries are landing.',
                    style: TextStyle(color: Color(0xFF64748B), height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  if (categoryCounts.isEmpty)
                    const _SummaryEmptyState()
                  else
                    ...categoryCounts.entries.map((entry) {
                      final ratio = expenses.isEmpty
                          ? 0.0
                          : entry.value / expenses.length;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _CategoryProgressCard(
                          category: entry.key,
                          count: entry.value,
                          ratio: ratio,
                        ),
                      );
                    }),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.totalInINR,
    required this.isLoading,
    required this.onRefresh,
  });

  final double totalInINR;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF115E59), Color(0xFF0F172A)],
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
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0x1FFFFFFF),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0x24FFFFFF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Spend in INR',
                    style: TextStyle(
                      color: Color(0xD9FFFFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rs ${totalInINR.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Converted totals help keep the summary easy to compare across currencies.',
                    style: TextStyle(color: Color(0xC7FFFFFF), height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.iconColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentHighlightCard extends StatelessWidget {
  const _RecentHighlightCard({required this.expense});

  final Expense? expense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: expense == null
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'No recent expense to highlight yet.',
                  style: TextStyle(color: Color(0xFF64748B), height: 1.5),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: expenseCategoryColor(
                      expense!.category,
                    ).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    expenseCategoryIcon(expense!.category),
                    color: expenseCategoryColor(expense!.category),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Latest Activity',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        expense!.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${expense!.category} • ${formatExpenseDate(expense!.date)}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${expenseCurrencySymbol(expense!.currency)}${expense!.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CategoryProgressCard extends StatelessWidget {
  const _CategoryProgressCard({
    required this.category,
    required this.count,
    required this.ratio,
  });

  final String category;
  final int count;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final accentColor = expenseCategoryColor(category);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(expenseCategoryIcon(category), color: accentColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count entr${count == 1 ? 'y' : 'ies'}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(ratio * 100).round()}%',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryEmptyState extends StatelessWidget {
  const _SummaryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Text(
        'Add a few expenses to unlock the breakdown cards here.',
        style: TextStyle(color: Color(0xFF64748B), height: 1.6),
      ),
    );
  }
}

Map<String, int> _buildCategoryCounts(List<Expense> expenses) {
  final counts = <String, int>{};

  for (final expense in expenses) {
    counts.update(expense.category, (value) => value + 1, ifAbsent: () => 1);
  }

  final entries = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return Map<String, int>.fromEntries(entries);
}
