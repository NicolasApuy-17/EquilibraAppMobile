import 'package:flutter/material.dart';

/// How many card columns fit in [width], each at least [minCardWidth] wide,
/// up to [maxColumns]. Used to turn a single-column `ListView.builder` of
/// cards (a patient list, a user list, ...) into a real 2-up grid on
/// tablets, where a single phone-width column otherwise leaves most of the
/// screen empty and reads as broken -- see `ResponsiveCardRow`, which
/// renders one row's worth of cards using this.
int responsiveColumnsFor(
  double width, {
  double minCardWidth = 340.0,
  int maxColumns = 2,
}) =>
    (width / minCardWidth).floor().clamp(1, maxColumns);

/// Renders up to [columns] items from [items] (starting at [rowIndex] *
/// [columns]) side by side, leaving a short last row's remaining slots
/// empty instead of stretching the final card to fill them. Meant to be
/// the entire body of a `ListView.builder`'s `itemBuilder`, with
/// `itemCount` computed as `(items.length / columns).ceil()` -- this keeps
/// the list lazy and compatible with `RefreshIndicator`/a `Stack`-
/// positioned `FloatingActionButton`, unlike switching to a `GridView` or
/// `Wrap` (which needs building every item eagerly and its own scroll
/// handling, losing the pull-to-refresh wiring already built around these
/// lists).
class ResponsiveCardRow<T> extends StatelessWidget {
  const ResponsiveCardRow({
    super.key,
    required this.items,
    required this.rowIndex,
    required this.columns,
    required this.itemBuilder,
    this.spacing = 12.0,
  });

  final List<T> items;
  final int rowIndex;
  final int columns;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (columns <= 1) {
      return itemBuilder(context, items[rowIndex]);
    }
    final start = rowIndex * columns;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < columns; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(
            child: start + i < items.length
                ? itemBuilder(context, items[start + i])
                : const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }
}
