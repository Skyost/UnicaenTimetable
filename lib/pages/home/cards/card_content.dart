import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/utils/brightness_listener.dart';

/// A home material card, draggable and with an id.
class MaterialCardContent extends ConsumerStatefulWidget {
  /// The color.
  final Color color;

  /// The icon.
  final IconData icon;

  /// The title.
  final String title;

  /// The subtitle.
  final String subtitle;

  /// Triggered when removed.
  final VoidCallback? onRemove;

  /// Triggered when tapped.
  final VoidCallback? onTap;

  /// Creates a new material card instance.
  const MaterialCardContent({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRemove,
    this.onTap,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MaterialCardContentState();
}

/// The material card content state.
class _MaterialCardContentState extends ConsumerState<MaterialCardContent> with BrightnessListener {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                stops: MediaQuery.sizeOf(context).width < 800 ? const [0.03, 0.03] : const [0.01, 0.01],
                colors: [widget.color, currentBrightness == Brightness.dark ? Theme.of(context).colorScheme.surfaceBright : widget.color.withAlpha(40)],
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.only(top: 20, right: 20, bottom: 20),
              leading: LayoutBuilder(
                builder: (_, constraints) => Padding(
                  padding: EdgeInsets.only(left: 0.03 * constraints.maxWidth + 20),
                  child: Icon(
                    widget.icon,
                    color: titleColor,
                    size: constraints.maxHeight,
                  ),
                ),
              ),
              title: Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              subtitle: Text(
                widget.subtitle,
                style: TextStyle(color: subtitleColor),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.close,
                  color: titleColor,
                ),
                onPressed: widget.onRemove,
              ),
              onTap: widget.onTap,
            ),
          ),
        ),
      );

  /// Returns the text color.
  Color get subtitleColor => currentBrightness == Brightness.dark ? Colors.white.withValues(alpha: 0.75) : widget.color;

  /// Returns the text color.
  Color get titleColor => currentBrightness == Brightness.dark ? Colors.white : widget.color;
}
