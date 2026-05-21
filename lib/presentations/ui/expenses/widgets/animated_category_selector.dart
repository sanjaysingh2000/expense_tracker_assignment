import 'package:assignment_01/presentations/utils/expense_ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnimatedCategorySelector extends StatelessWidget {
  const AnimatedCategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((category) {
        final isSelected = selectedCategory == category;
        final accentColor = expenseCategoryColor(category);

        return _AnimatedCategoryTile(
          label: category,
          icon: expenseCategoryIcon(category),
          accentColor: accentColor,
          isSelected: isSelected,
          onTap: () => onCategorySelected(category),
        );
      }).toList(),
    );
  }
}

class _AnimatedCategoryTile extends StatelessWidget {
  const _AnimatedCategoryTile({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1 : 0.97,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: 104,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.22),
                    accentColor.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.55)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.18)
                  : const Color(0x080F172A),
              blurRadius: isSelected ? 22 : 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor
                        : accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : accentColor,
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF475569),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                    fontSize: 14,
                  ),
                  child: Text(label),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: isSelected
                      ? Padding(
                          key: ValueKey(label),
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            width: 24,
                            height: 4,
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        )
                      : const SizedBox(
                          key: ValueKey('empty-indicator'),
                          height: 12,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
