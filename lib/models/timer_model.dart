import 'dart:async';

import 'package:flutter/material.dart';
import 'package:football_app/models/fixture_model.dart';

class TimerModel extends ChangeNotifier {
  Map<String, int> timers = {}; // stores the minutes passed
  Map<String, Timer?> _timers = {}; // actual timers
  Map<String, bool> isHalfTime = {}; // track if match is at halftime
  static const halfTimeDuration = Duration(minutes: 45);
  static const halfTimeBreakDuration = Duration(minutes: 15);

  // Start the timer
  void startRealTimeTimer(Fixture fixture) {
    DateTime fixtureStart = DateTime.parse(fixture.startingAt).toLocal();
    final now = DateTime.now();
    final elapsed = now.difference(fixtureStart).inMinutes;

    // If the match hasn't started, don't start the timer
    if (elapsed < 0) return;

    // Adjust elapsed time if the match is at halftime or full-time
    if (elapsed >= 90) {
      timers[fixture.id.toString()] = 90; // Full-time
      stopTimer(fixture.id.toString());
      notifyListeners();
      return;
    } else if (elapsed >= 45 && elapsed < 60) {
      timers[fixture.id.toString()] = 45; // Halftime
      notifyListeners();
      return;
    } else {
      timers[fixture.id.toString()] = elapsed; // Normal time
    }

    isHalfTime[fixture.id.toString()] = false;
    _timers[fixture.id.toString()]?.cancel(); // cancel any existing timer

    // Start the timer
    _timers[fixture.id.toString()] = Timer.periodic(
      const Duration(minutes: 1),
      (timer) => _updateTimer(fixture.id.toString(), timer),
    );
  }

  // Method to update the timer each minute
  void _updateTimer(String id, Timer timer) {
    timers[id] = timers[id]! + 1;
    notifyListeners(); // Update UI

    // Check for halftime or full-time
    if (timers[id] == 45) {
      _pauseTimerForHalfTime(id, timer);
    } else if (timers[id]! >= 90) {
      // Full-time reached
      timer.cancel();
      _timers.remove(id);
      notifyListeners();
    }
  }

  // Pause the timer at halftime
  void _pauseTimerForHalfTime(String id, Timer timer) {
    timer.cancel();
    isHalfTime[id] = true;
    notifyListeners(); // Update UI to show HT
    Future.delayed(halfTimeBreakDuration, () {
      // After 15 minutes of halftime, resume the timer
      resumeTimer(id);
    });
  }

  // Resume the timer after halftime
  void resumeTimer(String id) {
    if (_timers[id] != null) return; // Timer already running

    _timers[id] = Timer.periodic(const Duration(minutes: 1), (timer) {
      timers[id] = (timers[id]! + 1);
      notifyListeners();

      // Stop timer when reaching full-time (90+ minutes)
      if (timers[id]! >= 90) {
        timer.cancel();
        _timers.remove(id);
        notifyListeners();
      }
    });
    isHalfTime[id] = false; // Reset halftime flag
  }

  // Stop the timer at full-time or when the match ends
  void stopTimer(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
    // notifyListeners();
  }

  // Dispose of the timers when no longer needed
  @override
  void dispose() {
    _timers.forEach((id, timer) => timer?.cancel());
    super.dispose();
  }
}
