import 'package:flutter/material.dart';

// A simple service to notify listeners of changes to the task list.
class TaskService extends ChangeNotifier {
  void tasksUpdated() {
    notifyListeners();
  }
}
