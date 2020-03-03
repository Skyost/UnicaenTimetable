import 'package:flutter/material.dart';

/// An application model that can be initialized.
abstract class UnicaenTimetableModel extends ChangeNotifier {
  /// Whether this model instance has been initialized.
  bool isInitialized = false;

  /// Initializes this model instance.
  Future<void> initialize();

  /// Marks this model as initialized.
  @protected
  void markInitialized() {
    isInitialized = true;
    notifyListeners();
  }
}
