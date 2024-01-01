import 'dart:math' as math;

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/utils/widgets.dart';
import 'package:unicaen_timetable/widgets/flutter_week_view.dart';

/// A dialog that allows to prompt the user for a value.
abstract class _InputDialog<T> extends ConsumerStatefulWidget {
  /// The title text key.
  final String? titleKey;

  /// The initial value.
  final T? initialValue;

  /// The dialog content padding.
  final EdgeInsets contentPadding;

  /// Creates a new input dialog instance.
  const _InputDialog({
    super.key,
    this.titleKey,
    this.initialValue,
    this.contentPadding = const EdgeInsets.all(24),
  });
}

/// The input dialog state.
abstract class _InputDialogState<V, T extends _InputDialog<V>> extends ConsumerState<T> {
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: widget.titleKey == null ? null : Text(context.getString(widget.titleKey!)),
        contentPadding: widget.contentPadding,
        content: buildForm(context),
        actions: createActions(context),
      );

  /// Builds the dialog form.
  Widget buildForm(BuildContext context);

  /// Returns the current value.
  V? get value;

  /// Creates the actions.
  List<Widget> createActions(BuildContext context) => [
        createCancelButton(context),
        createOkButton(context),
      ];

  /// Creates the "Cancel" button.
  Widget createCancelButton(BuildContext context) => TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel.toUpperCase()),
      );

  /// Creates the "Ok" button.
  Widget createOkButton(BuildContext context) => TextButton(
        onPressed: () => Navigator.pop(context, value),
        child: Text(MaterialLocalizations.of(context).okButtonLabel.toUpperCase()),
      );
}

/// A text input dialog.
class TextInputDialog extends _InputDialog<String> {
  /// Creates a new text input dialog instance.
  const TextInputDialog({
    super.key,
    super.titleKey,
    super.initialValue,
  });

  @override
  ConsumerState createState() => _TextInputDialogState();

  /// Prompts the user for a text value.
  static Future<String?> getValue(
    BuildContext context, {
    String? titleKey,
    String? initialValue,
  }) =>
      showDialog<String?>(
        context: context,
        builder: (_) => TextInputDialog(
          titleKey: titleKey,
          initialValue: initialValue,
        ),
      );
}

/// The text input dialog state.
class _TextInputDialogState extends _InputDialogState<String, TextInputDialog> {
  /// The current text editing controller.
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget buildForm(BuildContext context) => TextField(controller: textEditingController);

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  String get value => textEditingController.text;
}

/// An integer input dialog.
class IntInputDialog extends _InputDialog<int> {
  /// Min int value.
  final int min;

  /// Max int value.
  final int max;

  /// Divisions count.
  final int divisions;

  /// Creates a new integer input dialog.
  const IntInputDialog({
    super.key,
    super.titleKey,
    super.initialValue,
    required this.min,
    required this.max,
    required this.divisions,
  });

  @override
  ConsumerState createState() => _IntInputDialogState();

  /// Prompts the user for an integer value.
  static Future<int?> getValue(
    BuildContext context, {
    String? titleKey,
    int? initialValue,
    required int min,
    required int max,
    required int divisions,
  }) =>
      showDialog<int?>(
        context: context,
        builder: (_) => IntInputDialog(
          titleKey: titleKey,
          initialValue: initialValue,
          min: min,
          max: max,
          divisions: divisions,
        ),
      );
}

/// The integer input dialog state.
class _IntInputDialogState extends _InputDialogState<int, IntInputDialog> {
  /// The current value.
  late int currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue ?? widget.min;
  }

  @override
  Widget buildForm(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            min: widget.min.toDouble(),
            max: widget.max.toDouble(),
            divisions: widget.divisions,
            value: currentValue.toDouble(),
            onChanged: (value) {
              setState(() => currentValue = value.toInt());
            },
          ),
          Text(currentValue.toString())
        ],
      );

  @override
  int get value => currentValue;
}

/// A boolean input dialog.
class BoolInputDialog extends _InputDialog<bool> {
  /// The message key.
  final String messageKey;

  /// The yes button key.
  final String yesButtonKey;

  /// The no button key.
  final String noButtonKey;

  /// Creates a new boolean input dialog.
  const BoolInputDialog({
    super.key,
    super.titleKey,
    required this.messageKey,
    required this.yesButtonKey,
    required this.noButtonKey,
  }) : super(
          initialValue: null,
        );

  @override
  ConsumerState createState() => _BoolInputDialogState();

  /// Prompts the user for a boolean value.
  static Future<bool?> getValue(
    BuildContext context, {
    String? titleKey,
    required String messageKey,
    required String yesButtonKey,
    required String noButtonKey,
  }) =>
      showDialog<bool?>(
        context: context,
        builder: (_) => BoolInputDialog(
          titleKey: titleKey,
          messageKey: messageKey,
          yesButtonKey: yesButtonKey,
          noButtonKey: noButtonKey,
        ),
      );
}

/// The boolean input dialog state.
class _BoolInputDialogState extends _InputDialogState<bool, BoolInputDialog> {
  @override
  Widget buildForm(BuildContext context) => SingleChildScrollView(
        child: Text(context.getString((widget).messageKey)),
      );

  @override
  Widget createOkButton(BuildContext context) => TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text(context.getString((widget).yesButtonKey).toUpperCase()),
      );

  @override
  Widget createCancelButton(BuildContext context) => TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text(context.getString((widget).noButtonKey).toUpperCase()),
      );

  @override
  bool? get value => null;
}

/// A color input dialog.
class ColorInputDialog extends _InputDialog<Color> {
  /// The target lesson.
  final Lesson lesson;

  /// Creates a new color input dialog.
  const ColorInputDialog({
    super.key,
    required this.lesson,
    super.titleKey,
    super.initialValue,
  });

  @override
  ConsumerState createState() => _ColorInputDialogState();

  /// Prompts the user for a color value.
  static Future<Color?> getValue(
    BuildContext context, {
    required Lesson lesson,
    String? titleKey,
    Color? initialValue,
  }) =>
      showDialog<Color?>(
        context: context,
        builder: (_) => ColorInputDialog(
          lesson: lesson,
          titleKey: titleKey,
          initialValue: initialValue,
        ),
      );
}

/// The color input dialog state.
class _ColorInputDialogState extends _InputDialogState<Color, ColorInputDialog> {
  /// The current color.
  late Color currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.initialValue ?? Colors.white;
  }

  @override
  Widget buildForm(BuildContext context) => ColorPicker(
        pickerColor: currentColor,
        onColorChanged: (color) {
          setState(() => currentColor = color);
        },
        labelTypes: const [],
      );

  @override
  Color get value => currentColor;

  @override
  List<Widget> createActions(BuildContext context) => [
        TextButton(
          onPressed: () {
            setState(() => currentColor = FlutterWeekViewWidget.computeColors(widget.lesson, settingsModel: ref.read(settingsModelProvider)).first);
          },
          child: Text(context.getString('dialogs.lesson_info.reset_color').toUpperCase()),
        ),
        ...super.createActions(context),
      ];
}

/// An available week input dialog.
class AvailableWeekInputDialog extends _InputDialog<DateTime> {
  /// Creates a new available week input dialog.
  const AvailableWeekInputDialog({
    super.key,
    super.titleKey,
    required DateTime super.initialValue,
  }) : super(
          contentPadding: const EdgeInsets.symmetric(vertical: 24),
        );

  @override
  ConsumerState createState() => _AvailableWeekInputDialogState();

  /// Prompts the user for an available week value.
  static Future<DateTime?> getValue(
    BuildContext context, {
    String? titleKey,
    required DateTime initialValue,
  }) =>
      showDialog<DateTime?>(
        context: context,
        builder: (_) => AvailableWeekInputDialog(
          titleKey: titleKey,
          initialValue: initialValue,
        ),
      );
}

/// The available week input dialog state.
class _AvailableWeekInputDialogState extends _InputDialogState<DateTime, AvailableWeekInputDialog> {
  /// Available weeks (got from a model).
  List<DateTime>? weeks;

  /// The currently selected week index.
  int? currentWeekIndex;

  /// The scroll controller.
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      List<DateTime> availableWeeks = await ref.read(lessonRepositoryProvider).availableWeeks;
      setState(() {
        weeks = availableWeeks;
        currentWeekIndex = weeks!.indexOf(widget.initialValue!);
      });
    });
  }

  @override
  Widget buildForm(BuildContext context) {
    if (weeks == null) {
      return const CenteredCircularProgressIndicator();
    }

    if (weeks!.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Text(context.getString('dialogs.week_picker.empty')),
      );
    }

    DateFormat formatter = DateFormat.yMMMd(EzLocalization.of(context)?.locale.languageCode);
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ScrollablePositionedList.builder(
        itemBuilder: (_, position) {
          DateTime monday = weeks![position];
          return ListTile(
            title: Text('${formatter.format(monday)} — ${formatter.format(monday.atSunday)}'),
            trailing: Radio<bool>(
              value: position == currentWeekIndex,
              groupValue: true,
              onChanged: (_) => onTap(position),
            ),
            onTap: () => onTap(position),
          );
        },
        itemCount: weeks!.length,
        initialScrollIndex: math.max(0, currentWeekIndex!),
      ),
    );
  }

  @override
  DateTime? get value => (currentWeekIndex == null || weeks == null) || currentWeekIndex! < 0 || currentWeekIndex! >= weeks!.length ? null : weeks![currentWeekIndex!];

  /// Handles on tap event.
  void onTap(int position) {
    setState(() => currentWeekIndex = position);
  }
}
