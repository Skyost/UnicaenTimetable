import 'dart:math' as math;

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/utils/widgets.dart';

/// A dialog that allows to prompt the user for a value.
abstract class _InputDialog<T> extends StatefulWidget {
  /// The title text key.
  final String titleKey;

  /// The initial value.
  final T initialValue;

  /// The dialog content padding.
  final EdgeInsets contentPadding;

  /// Creates a new input dialog instance.
  const _InputDialog({
    this.titleKey,
    this.initialValue,
    this.contentPadding = const EdgeInsets.all(24),
  });
}

/// The input dialog state.
abstract class _InputDialogState<T> extends State<_InputDialog<T>> {
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: widget.titleKey == null ? null : Text(context.getString(widget.titleKey)),
        contentPadding: widget.contentPadding,
        content: buildForm(context),
        actions: [
          createOkButton(context),
          createCancelButton(context),
        ],
      );

  /// Builds the dialog form.
  Widget buildForm(BuildContext context);

  /// Returns the current value.
  T get value;

  /// Creates the "Ok" button.
  Widget createOkButton(BuildContext context) => FlatButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel.toUpperCase()),
      );

  /// Creates the "Cancel" button.
  Widget createCancelButton(BuildContext context) => FlatButton(
        onPressed: () => Navigator.of(context).pop(value),
        child: Text(MaterialLocalizations.of(context).okButtonLabel.toUpperCase()),
      );
}

/// A text input dialog.
class TextInputDialog extends _InputDialog<String> {
  /// Creates a new text input dialog instance.
  const TextInputDialog({
    String titleKey,
    String initialValue,
  }) : super(
          titleKey: titleKey,
          initialValue: initialValue,
        );

  @override
  State<StatefulWidget> createState() => _TextInputDialogState();

  /// Prompts the user for a text value.
  static Future<String> getValue(
    BuildContext context, {
    String titleKey,
    String initialValue,
  }) =>
      showDialog<String>(
        context: context,
        builder: (_) => TextInputDialog(
          titleKey: titleKey,
          initialValue: initialValue,
        ),
      );
}

/// The text input dialog state.
class _TextInputDialogState extends _InputDialogState<String> {
  /// The current text editing controller.
  TextEditingController textEditingController;

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
    String titleKey,
    int initialValue,
    @required this.min,
    @required this.max,
    @required this.divisions,
  }) : super(
          titleKey: titleKey,
          initialValue: initialValue,
        );

  @override
  State<StatefulWidget> createState() => _IntInputDialogState();

  /// Prompts the user for an integer value.
  static Future<int> getValue(
    BuildContext context, {
    String titleKey,
    int initialValue,
    @required int min,
    @required int max,
    @required int divisions,
  }) =>
      showDialog<int>(
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
class _IntInputDialogState extends _InputDialogState<int> {
  /// The current value.
  int currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
  }

  @override
  Widget buildForm(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            min: (widget as IntInputDialog).min.toDouble(),
            max: (widget as IntInputDialog).max.toDouble(),
            divisions: (widget as IntInputDialog).divisions,
            value: currentValue.toDouble(),
            onChanged: (value) => setState(() {
              currentValue = value.toInt();
            }),
          ),
          Text(currentValue?.toString() ?? '?')
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
    String titleKey,
    @required this.messageKey,
    @required this.yesButtonKey,
    @required this.noButtonKey,
  }) : super(
          titleKey: titleKey,
          initialValue: null,
        );

  @override
  State<StatefulWidget> createState() => _BoolInputDialogState();

  /// Prompts the user for a boolean value.
  static Future<bool> getValue(
    BuildContext context, {
    String titleKey,
    @required String messageKey,
    @required String yesButtonKey,
    @required String noButtonKey,
  }) =>
      showDialog<bool>(
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
class _BoolInputDialogState extends _InputDialogState<bool> {
  @override
  Widget buildForm(BuildContext context) => SingleChildScrollView(
        child: Text(context.getString((widget as BoolInputDialog).messageKey)),
      );

  @override
  Widget createOkButton(BuildContext context) => FlatButton(
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(context.getString((widget as BoolInputDialog).yesButtonKey).toUpperCase()),
      );

  @override
  Widget createCancelButton(BuildContext context) => FlatButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(context.getString((widget as BoolInputDialog).noButtonKey).toUpperCase()),
      );

  @override
  bool get value => null;
}

/// A color input dialog.
class ColorInputDialog extends _InputDialog<Color> {
  /// Creates a new color input dialog.
  const ColorInputDialog({
    String titleKey,
    Color initialValue,
  }) : super(
          titleKey: titleKey,
          initialValue: initialValue,
        );

  @override
  State<StatefulWidget> createState() => _ColorInputDialogState();

  /// Prompts the user for a color value.
  static Future<Color> getValue(
    BuildContext context, {
    String titleKey,
    Color initialValue,
  }) =>
      showDialog<Color>(
        context: context,
        builder: (_) => ColorInputDialog(
          titleKey: titleKey,
          initialValue: initialValue,
        ),
      );
}

/// The color input dialog state.
class _ColorInputDialogState extends _InputDialogState<Color> {
  /// The current color.
  Color currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.initialValue ?? Colors.white;
  }

  @override
  Widget buildForm(BuildContext context) => ColorPicker(
        pickerColor: currentColor,
        onColorChanged: (color) => setState(() {
          currentColor = color;
        }),
        showLabel: false,
      );

  @override
  Color get value => currentColor;
}

/// An available week input dialog.
class AvailableWeekInputDialog extends _InputDialog<DateTime> {
  /// Creates a new available week input dialog.
  const AvailableWeekInputDialog({
    String titleKey,
    DateTime initialValue,
  }) : super(
          titleKey: titleKey,
          initialValue: initialValue,
          contentPadding: const EdgeInsets.symmetric(vertical: 24),
        );

  @override
  State<StatefulWidget> createState() => _AvailableWeekInputDialogState();

  /// Prompts the user for an available week value.
  static Future<DateTime> getValue(
    BuildContext context, {
    String titleKey,
    DateTime initialValue,
  }) =>
      showDialog<DateTime>(
        context: context,
        builder: (_) => AvailableWeekInputDialog(
          titleKey: titleKey,
          initialValue: initialValue,
        ),
      );
}

/// The available week input dialog state.
class _AvailableWeekInputDialogState extends _InputDialogState<DateTime> {
  /// Available weeks (got from a model).
  List<DateTime> weeks;

  /// The currently selected week index.
  int currentWeekIndex;

  /// The scroll controller.
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      List<DateTime> availableWeeks = await context.get<LessonModel>().availableWeeks;
      setState(() {
        weeks = availableWeeks;
        currentWeekIndex = weeks.indexOf(widget.initialValue);
      });
    });
  }

  @override
  Widget buildForm(BuildContext context) {
    if (weeks == null) {
      return const CenteredCircularProgressIndicator();
    }

    if (weeks.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Text(context.getString('dialogs.week_picker.empty')),
      );
    }

    DateFormat formatter = DateFormat.yMMMd(EzLocalization.of(context).locale.languageCode);
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ScrollablePositionedList.builder(
        itemBuilder: (_, position) {
          DateTime monday = weeks[position];
          return ListTile(
            title: Text(formatter.format(monday) + ' — ' + formatter.format(monday.add(const Duration(days: DateTime.friday)))),
            trailing: Radio<bool>(
              value: position == currentWeekIndex,
              groupValue: true,
              onChanged: (_) => onTap(position),
            ),
            onTap: () => onTap(position),
          );
        },
        itemCount: weeks.length,
        initialScrollIndex: math.max(0, currentWeekIndex),
      ),
    );
  }

  @override
  DateTime get value => currentWeekIndex < 0 || currentWeekIndex >= weeks.length ? null : weeks[currentWeekIndex];

  /// Handles on tap event.
  void onTap(int position) => setState(() {
        currentWeekIndex = position;
      });
}
