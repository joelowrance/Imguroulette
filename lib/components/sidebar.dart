import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:imgur_random/models/stats_tracker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SideBar extends StatelessWidget {
  const SideBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          DrawerHeader(
            child: Text('Load Statistics'),
          ),
          Center(
              child: Text(
            "Load Statistics",
            style: TextStyle(fontSize: 40),
          )),
          CircularPercentIndicator(
            radius: 130,
            animation: true,
            lineWidth: 15,
            percent: StatsTracker.instance.overall.percentSuccess,
            center: new Text(
              StatsTracker.instance.overall.percentDescription(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            backgroundColor: Colors.blueGrey[50],
            progressColor: Colors.green,
          ),
          Center(
              child: Text(
            StatsTracker.instance.overall.longDescription(),
            style: TextStyle(fontSize: 15),
          )),
          Padding(
            padding: EdgeInsets.all(10),
            child: Center(
                child: Text(
              'This application makes random requests to imgur.  The success rate is shown above',
              style: TextStyle(fontSize: 15),
            )),
          ),
        ],
      ),
    );
  }
}
