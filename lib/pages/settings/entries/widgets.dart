import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/settings/entry.dart';
import 'package:unicaen_timetable/utils/lesson_download.dart';
import 'package:unicaen_timetable/widgets/dialogs/input.dart';

/// Allows to configure boolean values.
class BoolSettingsEntryWidget<T extends SettingsEntry<bool>> extends CheckboxSettingsEntryWidget<T, bool> {
  /// Creates a new bool settings entry widget instance.
  const BoolSettingsEntryWidget({
    super.key,
    required super.provider,
    required super.title,
    super.subtitle,
    super.icon,
  });

  @override
  bool isEnabled(bool? value) => value == true;

  @override
  void changeValue(BuildContext context, WidgetRef ref, bool newValue) => ref.read(provider.notifier).changeValue(newValue);
}

/// A settings entry that can be configured using a checkbox.
abstract class CheckboxSettingsEntryWidget<T extends SettingsEntry<U>, U> extends ConsumerWidget {
  /// The boolean provider.
  final AutoDisposeAsyncNotifierProvider<T, U> provider;

  /// The entry widget title.
  final String title;

  /// The entry widget subtitle.
  final String? subtitle;

  /// The icon.
  final IconData? icon;

  /// The tile padding.
  final EdgeInsets? contentPadding;

  /// Creates a new checkbox settings entry widget instance.
  const CheckboxSettingsEntryWidget({
    super.key,
    required this.provider,
    required this.title,
    this.subtitle,
    this.icon,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<U> value = ref.watch(provider);
    return switch (value) {
      AsyncData(:final value) => createListTile(context, ref, value: value),
      AsyncError() => const SizedBox.shrink(),
      _ => createListTile(context, ref, enabled: false),
    };
  }

  /// Creates the list tile widget.
  Widget createListTile(BuildContext context, WidgetRef ref, {U? value, bool enabled = true}) => ListTile(
    leading: icon == null ? null : Icon(icon),
    title: Text(title),
    subtitle: buildSubtitle(context, ref, value),
    enabled: enabled,
    contentPadding: contentPadding,
    onTap: () => changeValue(context, ref, !isEnabled(value)),
    trailing: Checkbox(
      value: isEnabled(value),
      onChanged: enabled
          ? (value) {
              if (value != null) {
                changeValue(context, ref, value);
              }
            }
          : null,
    ),
  );

  /// Whether the checkbox is enabled.
  bool isEnabled(U? value);

  /// Builds the subtitle widget.
  Widget? buildSubtitle(BuildContext context, WidgetRef ref, U? value) => subtitle == null ? null : Text(subtitle!);

  /// Changes the value.
  void changeValue(BuildContext context, WidgetRef ref, bool newValue);
}

/// Allows to configure values with a dialog.
abstract class DialogSettingsEntryWidget<T extends SettingsEntry<U>, U> extends ConsumerWidget {
  /// The boolean provider.
  final AutoDisposeAsyncNotifierProvider<T, U> provider;

  /// The entry widget title.
  final String title;

  /// The icon.
  final IconData? icon;

  /// The tile padding.
  final EdgeInsets? contentPadding;

  /// Whether to trigger a sync after the change.
  final bool syncAfterChange;

  /// Creates a new text settings entry widget instance.
  const DialogSettingsEntryWidget({
    super.key,
    required this.provider,
    required this.title,
    this.icon,
    this.contentPadding,
    this.syncAfterChange = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<U> value = ref.watch(provider);
    return switch (value) {
      AsyncData(:final value) => createListTile(context, ref, value: value),
      AsyncError() => const SizedBox.shrink(),
      _ => createListTile(context, ref, enabled: false),
    };
  }

  /// Creates the list tile widget.
  Widget createListTile(BuildContext context, WidgetRef ref, {U? value, bool enabled = true}) => ListTile(
    leading: icon == null ? null : Icon(icon),
    title: Text(title),
    subtitle: buildSubtitle(context, ref, value),
    enabled: enabled,
    contentPadding: contentPadding,
    onTap: () async {
      U? newValue = await getValue(context, value);
      if (newValue != null) {
        await changeValue(ref, newValue);
      }
    },
  );

  /// Prompts the user for a new value.
  Future<U?> getValue(BuildContext context, U? value);

  /// Builds the subtitle widget.
  Widget? buildSubtitle(BuildContext context, WidgetRef ref, U? value) => Text(
    value == null || value.toString().isEmpty ? translations.common.other.empty : value.toString(),
  );

  /// Changes the value.
  Future<void> changeValue(WidgetRef ref, U newValue) async {
    await ref.read(provider.notifier).changeValue(newValue);
    if (syncAfterChange) {
      downloadLessons(ref);
    }
  }
}

/// Allows to configure integer values.
class IntegerSettingsEntryWidget<T extends SettingsEntry<int>> extends DialogSettingsEntryWidget<T, int> {
  /// Min int value.
  final int min;

  /// Max int value.
  final int max;

  /// Divisions count.
  final int divisions;

  /// Creates a new integer settings entry widget instance.
  const IntegerSettingsEntryWidget({
    super.key,
    required super.provider,
    required super.title,
    super.icon,
    super.contentPadding,
    super.syncAfterChange,
    required this.min,
    required this.max,
    required this.divisions,
  });

  @override
  Future<int?> getValue(BuildContext context, int? value) => IntInputDialog.getValue(
    context,
    min: min,
    max: max,
    divisions: divisions,
    initialValue: value,
  );
}

/// Allows to configure text values.
class StringSettingsEntryWidget<T extends SettingsEntry<String>> extends DialogSettingsEntryWidget<T, String> {
  /// The validator.
  final FormFieldValidator<String>? validator;

  /// The field hint.
  final String? hint;

  /// Creates a new text settings entry widget instance.
  const StringSettingsEntryWidget({
    super.key,
    required super.provider,
    required super.title,
    super.icon,
    super.contentPadding,
    super.syncAfterChange,
    this.validator,
    this.hint,
  });

  @override
  Future<String?> getValue(BuildContext context, String? value) => TextInputDialog.getValue(
    context,
    initialValue: value,
    validator: validator,
    hint: hint,
  );
}
