import 'package:flutter/material.dart';

class EventBus extends ChangeNotifier {
  static final EventBus _instance = EventBus._();
  factory EventBus() => _instance;
  EventBus._();

  String? _lastEvent;
  Map<String, dynamic>? _lastData;

  String? get lastEvent => _lastEvent;
  Map<String, dynamic>? get lastData => _lastData;

  void emit(String event, {Map<String, dynamic>? data}) {
    _lastEvent = event;
    _lastData = data;
    notifyListeners();
  }
}
