import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/utils/brightness_listener.dart';

/// A list page widget.
class ListPageWidget extends StatelessWidget {
  /// The list header.
  final Widget? header;

  /// The list body.
  final Widget? body;

  /// The list footer.
  final Widget? footer;

  /// Creates a new about page instance.
  const ListPageWidget({
    super.key,
    this.header,
    this.body,
    this.footer,
  });

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          if (header != null) header!,
          if (body != null) body!,
          if (footer != null) footer!,
        ],
      );
}

/// The about page list header.
class ListPageHeader extends ConsumerStatefulWidget {
  /// The icon.
  final Widget? icon;

  /// The title.
  final Widget? title;

  /// Creates a new list page header instance.
  const ListPageHeader({
    super.key,
    this.icon,
    this.title,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ListPageHeaderState();
}

/// The list header state.
class _ListPageHeaderState extends ConsumerState<ListPageHeader> with BrightnessListener {
  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).appBarTheme.backgroundColor,
        padding: const EdgeInsets.all(30),
        child: DefaultTextStyle(
          textAlign: TextAlign.center,
          style: TextStyle(
            color: defaultTextColor,
            fontSize: 30,
            fontWeight: FontWeight.w300,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null)
                SizedBox(
                  height: 100,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      iconTheme: Theme.of(context).iconTheme.copyWith(
                            color: defaultTextColor,
                            size: math.min(100, MediaQuery.sizeOf(context).width),
                          ),
                    ),
                    child: widget.icon!,
                  ),
                ),
              if (widget.title != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: widget.title!,
                ),
            ],
          ),
        ),
      );

  /// The default text color.
  Color get defaultTextColor => currentBrightness == Brightness.light ? Colors.white : Theme.of(context).colorScheme.primary;
}

/// The about page list body.
class ListPageBody extends StatelessWidget {
  /// The body children.
  final List<Widget> children;

  /// Creates a new list page body instance.
  const ListPageBody({
    super.key,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
}
