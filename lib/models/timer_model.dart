import 'dart:async';

import 'package:flutter/material.dart';
import 'package:football_app/models/fixture_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerModel extends ChangeNotifier {
  List<Fixture> fixtures = [];
  Map<String, int> timers = {};
  final Map<String, Timer?> _timers = {};
  Map<String, bool> isHalfTime = {};
  static const halfTimeDuration = Duration(minutes: 45);
  static const halfTimeBreakDuration = Duration(minutes: 15);

  // TimerModel() {
  //   initializeTimers();
  // }

  // void initializeTimers() {
  //   final now = DateTime.now();
  //   for (var fixture in fixtures) {
  //     if (toTime(DateTime.parse(fixture.startingAt)) == toTime(now)) {
  //       startTimer(fixture);
  //     }
  //   }
  //   // notifyListeners();
  // }

  void startTimer(Fixture fixture) {
    _loadDuration(fixture.id.toString()).then((duration) {
      timers[fixture.id.toString()] = duration;
      isHalfTime[fixture.id.toString()] = false;
      _timers[fixture.id.toString()]?.cancel();
      _timers[fixture.id.toString()] =
          Timer.periodic(const Duration(minutes: 1), (timer) {
        _updateTimer(fixture, timer);
      });
    });
  }

  void _updateTimer(Fixture fixture, Timer timer) {
    if (isHalfTime[fixture.id.toString()]!) return;
    timers[fixture.id.toString()] = timers[fixture.id.toString()]! + 1;
    _saveDuration(fixture.id.toString(), timers[fixture.id.toString()]!);
    notifyListeners();

    if (timers[fixture.id.toString()]! >= halfTimeDuration.inMinutes &&
        timers[fixture.id.toString()]! < halfTimeDuration.inMinutes + 1) {
      _pauseTimerForHalfTime(fixture, timer);
    }
  }

  void _pauseTimerForHalfTime(Fixture fixture, Timer timer) {
    timer.cancel();
    _timers.remove(fixture.id.toString());
    isHalfTime[fixture.id.toString()] = true;
    notifyListeners();

    Future.delayed(halfTimeBreakDuration, () {
      _resumeTimer(fixture);
    });
  }

  void _resumeTimer(Fixture fixture) {
    _timers[fixture.id.toString()] =
        Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateTimer(fixture, timer);
    });
  }

  Future<void> _saveDuration(String id, int duration) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timer_duration_$id', duration);
  }

  Future<int> _loadDuration(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('timer_duration_$id') ?? 0;
  }

  void stopTimer(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
  }

  @override
  void dispose() {
    _timers.forEach((id, timer) => timer?.cancel());
    super.dispose();
  }

  Duration getDuration(String id) {
    int minutes = timers[id] ?? 0;
    return Duration(minutes: minutes);
  }
}

String toTime(DateTime dateTime) {
  return DateFormat('hh:mm a').format(dateTime.toLocal());
}
