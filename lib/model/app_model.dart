import 'package:flutter/material.dart';

abstract class AppModel extends ChangeNotifier {
  bool isInitialized = false;

  Future<void> initialize();

  @protected
  void markInitialized() {
    isInitialized = true;
    notifyListeners();
  }
}
