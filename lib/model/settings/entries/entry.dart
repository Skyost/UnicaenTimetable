import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pedantic/pedantic.dart';
import 'package:unicaen_timetable/dialogs/input.dart';
import 'package:unicaen_timetable/model/settings/renderable.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/pages/scaffold.dart';

/// A settings entry.
class SettingsEntry<T> extends ChangeNotifier with RenderableSettingsObject {
  /// This entry key.
  final String key;

  /// Whether this entry is mutable.
  final bool mutable;

  /// Whether this entry is enabled and should be shown.
  final bool enabled;

  /// This entry value.
  T _value;

  /// Creates a new settings entry instance.
  SettingsEntry({
    String keyPrefix = '',
    @required String key,
    this.mutable = true,
    this.enabled = true,
    @required T value,
  })  : key = (keyPrefix.isEmpty ? '' : (keyPrefix + '.')) + key,
        _value = value;

  /// Loads this entry value from the settings box.
  Future<void> load([Box settingsBox]) async {
    Box box = settingsBox ?? await Hive.openBox(SettingsModel.HIVE_BOX);
    _value = decodeValue(box.get(key));
  }

  /// Returns this entry current value.
  T get value => _value;

  /// Sets this entry value.
  set value(T value) {
    if (!mutable) {
      return;
    }

    _value = value;
    notifyListeners();
  }

  /// Flushes this entry value to the settings box.
  Future<void> flush([Box settingsBox]) async {
    if (!mutable) {
      return;
    }

    Box box = settingsBox ?? await Hive.openBox(SettingsModel.HIVE_BOX);
    await box.put(key, value);
  }

  /// Decodes the value that was read from a Hive box.
  @protected
  T decodeValue(dynamic boxValue) => boxValue ?? _value;

  @override
  Widget render(BuildContext context) => SettingsEntryWidget(entry: this);
}

/// A widget that shows a settings entry.
class SettingsEntryWidget extends StatelessWidget {
  /// The settings entry.
  final SettingsEntry entry;

  /// Creates a new settings entry widget instance.
  const SettingsEntryWidget({
    @required this.entry,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: () => onTap(context),
        title: Text(context.getString('settings.${entry.key}')),
        subtitle: createSubtitle(context),
        trailing: createController(context),
      );

  /// Creates the subtitle widget.
  Widget createSubtitle(BuildContext context) {
    if (entry.value is String) {
      return Text(entry.value == null || entry.value.isEmpty ? context.getString('other.empty') : entry.value);
    }
    return null;
  }

  /// Creates the controller widget.
  Widget createController(BuildContext context) {
    if (entry.value is bool) {
      return Switch(
        value: entry.value,
        onChanged: (_) => onTap(context),
      );
    }

    return null;
  }

  /// Triggered before running the "on tap" action.
  Future<bool> beforeOnTap(BuildContext context) => Future<bool>.value(true);

  /// Triggered when the user has tapped the controller.
  Future<void> onTap(BuildContext context) async {
    bool result = await beforeOnTap(context);
    if (!result) {
      return;
    }

    if (entry.value is bool) {
      entry.value = !entry.value;
      unawaited(entry.flush());
    }

    if (entry.value is String) {
      String value = await TextInputDialog.getValue(
        context,
        titleKey: 'settings.${entry.key}',
        initialValue: entry.value,
      );

      if (value == null || value == entry.value) {
        return;
      }

      entry.value = value;
      unawaited(entry.flush());
    }

    unawaited(afterOnTap(context));
  }

  /// Triggered after the user has tapped the controller.
  Future<void> afterOnTap(BuildContext context) async {
    if (entry.key.startsWith('server.')) {
      unawaited(SynchronizeFloatingButton.onPressed(context));
    }
  }
}

/// Allows to display a dropdown button for a settings entry.
class SettingsDropdownButton<T> extends StatelessWidget {
  /// The title key of this settings entry.
  final String titleKey;

  /// Items to be displayed.
  final List<DropdownMenuItem<T>> items;

  /// The current value.
  final T value;

  /// Triggered when the value has been changed.
  final Function(T value) onChanged;

  /// Creates a new settings dropdown button instance.
  const SettingsDropdownButton({
    @required this.titleKey,
    @required this.items,
    @required this.value,
    @required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          title: Text(context.getString(titleKey) + ' :'),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: DropdownButton(
              isExpanded: true,
              onChanged: onChanged,
              items: items,
              value: value,
            ),
          ),
        ),
      );
}
