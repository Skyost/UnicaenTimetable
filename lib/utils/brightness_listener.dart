import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/settings/theme.dart';

/// Allows to listen to the platform's brightness.
mixin BrightnessListener<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// The current brightness.
  Brightness _currentBrightness = Brightness.light;

  /// The current theme mode.
  ThemeMode _currentThemeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      themeSettingsEntryProvider,
      onThemeSettingsEntryChange,
      fireImmediately: true,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Brightness brightness = MediaQuery.platformBrightnessOf(context);
    if (currentBrightness != brightness) {
      onBrightnessChange(brightness);
    }
  }

  @protected
  void onBrightnessChange(Brightness brightness) {
    void changeBrightness() => _currentBrightness = brightness;
    if (mounted) {
      setState(changeBrightness);
    } else {
      changeBrightness();
    }
  }

  /// Triggered when [themeSettingsEntryProvider] has changed.
  @protected
  void onThemeSettingsEntryChange(AsyncValue<ThemeMode>? previous, AsyncValue<ThemeMode> next) {
    ThemeMode themeMode = next.valueOrNull ?? ThemeMode.system;
    void changeThemeMode() => _currentThemeMode = themeMode;
    if (mounted) {
      setState(changeThemeMode);
    } else {
      changeThemeMode();
    }
  }

  /// Returns the current brightness.
  Brightness get currentBrightness => switch (_currentThemeMode) {
    ThemeMode.system => _currentBrightness,
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
  };
}
