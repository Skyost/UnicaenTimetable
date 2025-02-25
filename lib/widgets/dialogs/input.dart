import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';

/// A dialog that allows to prompt the user for a value.
abstract class _InputDialog<T> extends ConsumerStatefulWidget {
  /// The title text key.
  final String? title;

  /// The initial value.
  final T? initialValue;

  /// The dialog content padding.
  final EdgeInsets contentPadding;

  /// Creates a new input dialog instance.
  const _InputDialog({
    super.key,
    this.title,
    this.initialValue,
    this.contentPadding = const EdgeInsets.all(24),
  });
}

/// The input dialog state.
abstract class _InputDialogState<V, T extends _InputDialog<V>> extends ConsumerState<T> {
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: widget.title == null ? null : Text(widget.title!),
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
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
      );

  /// Creates the "Ok" button.
  Widget createOkButton(BuildContext context, {bool? enabled}) => TextButton(
        onPressed: enabled == true || enabled == null ? (() => Navigator.pop(context, value)) : null,
        child: Text(MaterialLocalizations.of(context).okButtonLabel),
      );
}

/// A text input dialog.
class TextInputDialog extends _InputDialog<String> {
  /// The validator.
  final FormFieldValidator<String>? validator;

  /// The field hint.
  final String? hint;

  /// Creates a new text input dialog instance.
  const TextInputDialog({
    super.key,
    super.title,
    super.initialValue,
    this.validator,
    this.hint,
  });

  @override
  ConsumerState createState() => _TextInputDialogState();

  /// Prompts the user for a text value.
  static Future<String?> getValue(
    BuildContext context, {
    String? title,
    String? initialValue,
    FormFieldValidator<String>? validator,
    String? hint,
  }) =>
      showDialog<String?>(
        context: context,
        builder: (_) => TextInputDialog(
          title: title,
          initialValue: initialValue,
          validator: validator,
          hint: hint,
        ),
      );

  /// Validates [value] if non empty.
  static String? validateNotEmpty(String? value) => value == null || value.trim().isEmpty ? translations.common.other.fieldEmpty : null;
}

/// The text input dialog state.
class _TextInputDialogState extends _InputDialogState<String, TextInputDialog> {
  /// The current text editing controller.
  late TextEditingController textEditingController = TextEditingController(text: widget.initialValue);

  /// Whether the "OK" button is enabled.
  late bool okEnabled = widget.validator?.call(widget.initialValue) == null;

  @override
  Widget buildForm(BuildContext context) => TextFormField(
        controller: textEditingController,
        validator: widget.validator,
        decoration: widget.hint == null
            ? null
            : InputDecoration(
                hintText: TextInputDialog.validateNotEmpty(widget.hint) == null ? widget.hint : translations.common.other.empty,
              ),
        autovalidateMode: widget.validator == null ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
        onChanged: widget.validator == null
            ? null
            : ((value) {
                setState(() => okEnabled = widget.validator!(value) == null);
              }),
      );

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget createOkButton(BuildContext context, {bool? enabled}) {
    enabled ??= okEnabled;
    return super.createOkButton(context, enabled: enabled);
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
    super.title,
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
    String? title,
    int? initialValue,
    required int min,
    required int max,
    required int divisions,
  }) =>
      showDialog<int?>(
        context: context,
        builder: (_) => IntInputDialog(
          title: title,
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

/// A color input dialog.
class ColorInputDialog extends _InputDialog<Color> {
  /// The default color.
  final Color? resetColor;

  /// Creates a new color input dialog.
  const ColorInputDialog({
    super.key,
    this.resetColor,
    super.title,
    super.initialValue,
  });

  @override
  ConsumerState createState() => _ColorInputDialogState();

  /// Prompts the user for a color value.
  static Future<Color?> getValue(
    BuildContext context, {
    Color? resetColor,
    String? title,
    Color? initialValue,
  }) =>
      showDialog<Color?>(
        context: context,
        builder: (_) => ColorInputDialog(
          resetColor: resetColor,
          title: title,
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
  Widget buildForm(BuildContext context) => SingleChildScrollView(
        child: ColorPicker(
          pickerColor: currentColor,
          onColorChanged: (color) {
            setState(() => currentColor = color);
          },
          labelTypes: const [],
        ),
      );

  @override
  Color get value => currentColor;

  @override
  List<Widget> createActions(BuildContext context) => [
        if (widget.resetColor != null)
          TextButton(
            onPressed: () {
              setState(() => currentColor = widget.resetColor!);
            },
            child: Text(translations.dialogs.lessonInfo.resetColor),
          ),
        ...super.createActions(context),
      ];
}

/// An available week input dialog.
class MultiChoicePickerDialog<T> extends _InputDialog<T> {
  /// The available values.
  final List<T> values;

  /// The message to display if empty.
  final String emptyMessage;

  /// Converts a [T] to a readable [String].
  final String Function(T)? valueToString;

  /// Creates a new available week input dialog.
  const MultiChoicePickerDialog({
    super.key,
    super.title,
    super.initialValue,
    this.values = const [],
    required this.emptyMessage,
    this.valueToString,
  }) : super(
          contentPadding: const EdgeInsets.symmetric(vertical: 24),
        );

  @override
  ConsumerState createState() => _AvailableWeekInputDialogState<T>();

  /// Prompts the user for an available week value.
  static Future<T?> getValue<T>(
    BuildContext context, {
    String? title,
    T? initialValue,
    List<T>? values,
    required String emptyMessage,
    String Function(T)? valueToString,
  }) =>
      showDialog<T?>(
        context: context,
        builder: (_) => MultiChoicePickerDialog<T>(
          title: title,
          initialValue: initialValue,
          values: values ?? [],
          emptyMessage: emptyMessage,
          valueToString: valueToString,
        ),
      );
}

/// The available week input dialog state.
class _AvailableWeekInputDialogState<T> extends _InputDialogState<T, MultiChoicePickerDialog<T>> {
  /// The currently selected week index.
  late int currentValueIndex = widget.initialValue == null ? -1 : widget.values.indexOf(widget.initialValue!);

  @override
  Widget buildForm(BuildContext context) {
    if (widget.values.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Text(widget.emptyMessage),
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ScrollablePositionedList.builder(
        itemBuilder: (_, position) {
          T value = widget.values[position];
          return ListTile(
            title: Text(widget.valueToString?.call(value) ?? value.toString()),
            trailing: Radio<int>(
              value: position,
              groupValue: currentValueIndex,
              onChanged: (_) => onTap(position),
            ),
            onTap: () => onTap(position),
          );
        },
        itemCount: widget.values.length,
        initialScrollIndex: math.max(0, currentValueIndex),
      ),
    );
  }

  @override
  Widget createCancelButton(BuildContext context) => widget.values.isEmpty ? const SizedBox.shrink() : super.createCancelButton(context);

  @override
  T? get value => (currentValueIndex == -1 || widget.values.isEmpty) || currentValueIndex < 0 || currentValueIndex >= widget.values.length ? null : widget.values[currentValueIndex];

  /// Handles on tap event.
  void onTap(int position) {
    setState(() => currentValueIndex = position);
  }
}
