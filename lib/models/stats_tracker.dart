import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StatsTracker {
  StatsTracker._privateConstructor();
  static final StatsTracker _instance = StatsTracker._privateConstructor();
  static StatsTracker get instance {
    return _instance;
  }

  StatsDisplay overall;
  StatsDisplay fives;
  StatsDisplay sevens;

  final List<LoadResult> _stats = [];

  void addStat(int length, bool success) {
    _stats.add(new LoadResult(length: length, success: success));
  }

  void calculate() {
    overall = StatsDisplay(
        totalRequests: _stats.length,
        totalSuccess: _stats.where((x) => x.success).length);

    var five = _stats.where((x) => x.length == 5);
    fives = StatsDisplay(
        totalRequests: five.length,
        totalSuccess: five.where((x) => x.success).length);

    var seven = _stats.where((x) => x.length == 7);
    sevens = StatsDisplay(
        totalRequests: seven.length,
        totalSuccess: seven.where((x) => x.success).length);
  }
}

class StatsDisplay {
  int totalRequests;
  int totalSuccess;
  double percentSuccess;

  StatsDisplay({
    this.totalRequests,
    this.totalSuccess,
  }) {
    percentSuccess = (totalSuccess / totalRequests);
  }

  String percentDescription() {
    return '${(percentSuccess * 100).toStringAsFixed(2)}%';
  }

  String description() {
    return "$totalSuccess / $totalRequests";
  }

  String longDescription() {
    return '$totalRequests requests made, $totalSuccess were successful';
  }
}

class LoadResult {
  final int length;
  final bool success;

  const LoadResult({@required this.length, @required this.success});
}
