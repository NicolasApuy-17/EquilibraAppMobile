import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

/// Wraps a screen's scrollable [content] and its fixed bottom nav bar
/// ([bottomNav]) so the bar slides away while the patient drags up through
/// the content (a clean, full-screen read) and slides back in as soon as
/// they drag back down -- regardless of whether [content] is a
/// `SingleChildScrollView` or a `ListView`, since both bubble up the same
/// `ScrollNotification`s this widget listens for.
class ScrollHidingBottomNav extends StatefulWidget {
  const ScrollHidingBottomNav({
    super.key,
    required this.content,
    required this.bottomNav,
  });

  final Widget content;
  final Widget bottomNav;

  @override
  State<ScrollHidingBottomNav> createState() => _ScrollHidingBottomNavState();
}

class _ScrollHidingBottomNavState extends State<ScrollHidingBottomNav> {
  bool _visible = true;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      final direction = notification.direction;
      if (direction == ScrollDirection.reverse && _visible) {
        setState(() => _visible = false);
      } else if (direction == ScrollDirection.forward && !_visible) {
        setState(() => _visible = true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: widget.content,
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _visible ? widget.bottomNav : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
