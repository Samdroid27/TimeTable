import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../providers/tt_provider.dart';
import '../widgets/timetable_display.dart';
import '../main.dart';

class TTScreen extends StatefulWidget {
  @override
  _TTScreenState createState() => _TTScreenState();
}

class _TTScreenState extends State<TTScreen> {
  var _isNotificationOn = false;

  final MethodChannel platform =
      MethodChannel('crossingthestreams.io/resourceResolver');

  @override
  void initState() {
    super.initState();
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SecondScreen(receivedNotification.title)),
                );
              },
            )
          ],
        ),
      );
    });
    selectNotificationSubject.stream.listen((String payload) async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TTScreen()),
      );
    });
    checkNotify();
  }

  Future<void> checkNotify() async {
    var notifications = await _checkPendingNotificationRequests();
    if (notifications > 0) {
      _isNotificationOn = true;
    } else {
      _isNotificationOn = false;
    }
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  void reset(BuildContext context) {
    for (var i = 8; i <= 17; i++) {
      Provider.of<TTProvider>(context).updateSlot(i, 'mon', '');
      Provider.of<TTProvider>(context).updateSlot(i, 'tue', '');
      Provider.of<TTProvider>(context).updateSlot(i, 'wed', '');
      Provider.of<TTProvider>(context).updateSlot(i, 'thu', '');
      Provider.of<TTProvider>(context).updateSlot(i, 'fri', '');
      Provider.of<TTProvider>(context).updateSlot(i, 'sat', '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Table'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.cached),
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Are you Sure?'),
                content: Text(
                  'Do you want to clear all Entries?',
                  softWrap: true,
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('NO'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  FlatButton(
                    child: Text('YES'),
                    onPressed: () {
                      reset(context);
                      Navigator.of(context).pop(true);
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5)),
              child: FutureBuilder(
                future: checkNotify(),
                builder: (ctx, snapshot) => SwitchListTile(
                  title: Text('Notification for classes'),
                  value: _isNotificationOn,
                  onChanged: (newVal) {
                    _isNotificationOn = newVal;
                    if (newVal == true) {
                      _onNotification(context);
                      _checkPendingNotificationRequests();
                    }
                    if (newVal == false) {
                      _cancelAllNotifications();
                    }
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                    Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, 1],
                ),
              ),
              child: TimeTableDisplay(),
            ),
            Container(
              height: 150,
              width: double.infinity,
              color: Color.fromRGBO(255, 188, 117, 1).withOpacity(0.3),
              child: Center(
                child: Text(
                  'TIME TABLE ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<void> _cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

Future<int> _checkPendingNotificationRequests() async {
  var pendingNotificationRequests =
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  for (var pendingNotificationRequest in pendingNotificationRequests) {
    debugPrint(
        'pending notification: [id: ${pendingNotificationRequest.id}, title: ${pendingNotificationRequest.title}, body: ${pendingNotificationRequest.body}, payload: ${pendingNotificationRequest.payload}]');
  }
  return pendingNotificationRequests.length;
}

Future<void> _showWeeklyAtDayAndTime(
    int hr, Day day, String course, int id) async {
  var time = Time(hr + 2, 53, 0);
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'show weekly channel id',
      'show weekly channel name',
      'show weekly description');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      id, course, 'Class in 10 min', day, time, platformChannelSpecifics);
}

void _onNotification(BuildContext context) {
  final items = Provider.of<TTProvider>(context).items;
  [...items].forEach((slot) {
    if (slot.mon != "") {
      _showWeeklyAtDayAndTime(slot.hr, Day.Monday, slot.mon, slot.hr * 10 + 1);
    }
    if (slot.tue != "") {
      _showWeeklyAtDayAndTime(slot.hr, Day.Tuesday, slot.tue, slot.hr * 10 + 2);
    }
    if (slot.wed != "") {
      _showWeeklyAtDayAndTime(
          slot.hr, Day.Wednesday, slot.wed, slot.hr * 10 + 3);
    }
    if (slot.thu != "") {
      _showWeeklyAtDayAndTime(
          slot.hr, Day.Thursday, slot.thu, slot.hr * 10 + 4);
    }
    if (slot.fri != "") {
      _showWeeklyAtDayAndTime(slot.hr, Day.Friday, slot.fri, slot.hr * 10 + 5);
    }
    if (slot.sat != "") {
      _showWeeklyAtDayAndTime(
          slot.hr, Day.Saturday, slot.sat, slot.hr * 10 + 6);
    }
  });
}

class SecondScreen extends StatefulWidget {
  SecondScreen(this.payload);

  final String payload;

  @override
  State<StatefulWidget> createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  String _payload;
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${(_payload ?? '')}'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('Class in 10 min'),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Go back!'),
            ),
          ],
        ),
      ),
    );
  }
}
