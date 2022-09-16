import 'package:flutter/material.dart';
import 'package:unicaen_timetable/model/storage/storage.dart';

/// An application model that can be initialized.
abstract class UnicaenTimetableModel extends ChangeNotifier {
  /// Allows to access storage.
  @protected
  static final Storage storage = Storage();

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
