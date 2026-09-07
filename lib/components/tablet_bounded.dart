import 'package:flutter/material.dart';

/// Caps content width on large screens (tablets) and centers it, so text,
/// cards and buttons don't stretch edge-to-edge and look out of place --
/// this app was designed phone-first, and a `Row`/`Column` sized for a
/// ~400dp-wide phone reads as sparse and disorganized when it's suddenly
/// given 1000dp+ of tablet width instead. A no-op on a normal phone: with
/// `maxWidth` only ever *constraining*, a screen narrower than it already
/// takes 100% of the width, unaffected.
///
/// Meant to wrap a `Scaffold`'s `body` as a whole (see home_screen_widget.dart,
/// psychologist_home_widget.dart, etc.) rather than being threaded through
/// every individual screen's internals -- one wrapper covers everything
/// inside it, including a `TabBarView`'s tabs.
class TabletBounded extends StatelessWidget {
  const TabletBounded({super.key, required this.child, this.maxWidth = 700.0});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
