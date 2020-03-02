import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/utils/utils.dart';

abstract class _InputDialog<T> extends StatefulWidget {
  final String titleKey;
  final T initialValue;
  final EdgeInsets contentPadding;

  const _InputDialog({
    this.titleKey,
    this.initialValue,
    this.contentPadding = const EdgeInsets.all(24),
  });
}

abstract class _InputDialogState<T> extends State<_InputDialog<T>> {
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: widget.titleKey == null ? null : Text(EzLocalization.of(context).get(widget.titleKey)),
        contentPadding: widget.contentPadding,
        content: buildForm(context),
        actions: [
          createOkButton(context),
          createCancelButton(context),
        ],
      );

  Widget buildForm(BuildContext context);

  T get value;

  Widget createOkButton(BuildContext context) => FlatButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel.toUpperCase()),
      );

  Widget createCancelButton(BuildContext context) => FlatButton(
        onPressed: () => Navigator.of(context).pop(value),
        child: Text(MaterialLocalizations.of(context).okButtonLabel.toUpperCase()),
      );
}

class TextInputDialog extends _InputDialog<String> {
  TextInputDialog({
    String titleKey,
    String initialValue,
  }) : super(
          titleKey: titleKey,
          initialValue: initialValue,
        );

  @override
  State<StatefulWidget> createState() => _TextInputDialogState();

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

class _TextInputDialogState extends _InputDialogState<String> {
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

class IntInputDialog extends _InputDialog<int> {
  final int min;
  final int max;
  final int divisions;

  IntInputDialog({
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

class _IntInputDialogState extends _InputDialogState<int> {
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

class BoolInputDialog extends _InputDialog<bool> {
  final String messageKey;
  final String yesButtonKey;
  final String noButtonKey;

  BoolInputDialog({
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

class _BoolInputDialogState extends _InputDialogState<bool> {
  @override
  Widget buildForm(BuildContext context) => SingleChildScrollView(
        child: Text(EzLocalization.of(context).get((widget as BoolInputDialog).messageKey)),
      );

  @override
  Widget createOkButton(BuildContext context) => FlatButton(
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(EzLocalization.of(context).get((widget as BoolInputDialog).yesButtonKey).toUpperCase()),
      );

  @override
  Widget createCancelButton(BuildContext context) => FlatButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(EzLocalization.of(context).get((widget as BoolInputDialog).noButtonKey).toUpperCase()),
      );

  @override
  bool get value => null;
}

class ColorInputDialog extends _InputDialog<Color> {
  ColorInputDialog({
    String titleKey,
    Color initialValue,
  }) : super(
          titleKey: titleKey,
          initialValue: initialValue,
        );

  @override
  State<StatefulWidget> createState() => _ColorInputDialogState();

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

class _ColorInputDialogState extends _InputDialogState<Color> {
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

class AvailableWeekInputDialog extends _InputDialog<DateTime> {
  AvailableWeekInputDialog({
    String titleKey,
    DateTime initialValue,
  }) : super(
          titleKey: titleKey,
          initialValue: initialValue,
          contentPadding: const EdgeInsets.symmetric(vertical: 24),
        );

  @override
  State<StatefulWidget> createState() => _AvailableWeekInputDialogState();

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

class _AvailableWeekInputDialogState extends _InputDialogState<DateTime> {
  List<DateTime> weeks;
  DateTime currentWeek;

  @override
  void initState() {
    super.initState();

    currentWeek = widget.initialValue;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      List<DateTime> availableWeeks = await Provider.of<LessonModel>(context, listen: false).availableWeeks;
      setState(() {
        weeks = availableWeeks;
      });
    });
  }

  @override
  Widget buildForm(BuildContext context) {
    if (weeks == null) {
      return const CenteredCircularProgressIndicator();
    }

    if (weeks.isEmpty) {
      return Text(EzLocalization.of(context).get('dialogs.week_picker.empty'));
    }

    DateFormat formatter = DateFormat.yMMMd(EzLocalization.of(context).locale.languageCode);
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        itemBuilder: (_, position) {
          DateTime monday = weeks[position];
          return ListTile(
            title: Text(formatter.format(monday) + ' — ' + formatter.format(monday.add(Duration(days: DateTime.friday - 1)))),
            trailing: Radio<bool>(
              value: currentWeek == monday,
              groupValue: true,
              onChanged: (_) => onTap(monday),
            ),
            onTap: () => onTap(monday),
          );
        },
        itemCount: weeks.length,
        shrinkWrap: true,
      ),
    );
  }

  @override
  DateTime get value => currentWeek;

  void onTap(DateTime monday) => setState(() {
        currentWeek = monday;
      });
}
