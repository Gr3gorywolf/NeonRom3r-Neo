import 'package:flutter/material.dart';

enum ViewModeToggleMode {
  list,
  grid,
}

class ViewModeToggle extends StatelessWidget {
  final ViewModeToggleMode value;
  final ValueChanged<ViewModeToggleMode> onChanged;

  const ViewModeToggle({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      constraints: BoxConstraints(
        minWidth: 120,
      ),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            active: value == ViewModeToggleMode.list,
            icon: Icons.view_list,
            label: 'List',
            onTap: () => onChanged(ViewModeToggleMode.list),
          ),
          _Segment(
            active: value == ViewModeToggleMode.grid,
            icon: Icons.grid_view,
            label: 'Grid',
            onTap: () => onChanged(ViewModeToggleMode.grid),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Segment({
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? colors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color:
                  active ? colors.primary : colors.onSurface.withOpacity(0.5),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color:
                    active ? colors.primary : colors.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
