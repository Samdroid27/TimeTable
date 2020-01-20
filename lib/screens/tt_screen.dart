import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../providers/tt_provider.dart';
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
                      MyApp()
                  ),
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
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    });
    checkNotify();
    
  }


  Future<void> checkNotify() async{
    var notifications = await _checkPendingNotificationRequests();
    if (notifications > 0){
      _isNotificationOn= true;
    }
    else
    {
      _isNotificationOn =false;
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
            onPressed: ()=> reset(context),
          )
        ],
      ),
      body: SingleChildScrollView(
              child: Column(
          children: <Widget>[
            PaddedRaisedButton(
                      buttonText: 'Show plain notification with payload',
                      onPressed: () async {
                        await _showNotification();
                      },
                    ),
             SwitchListTile(
               title: Text('Notification for classes'),
               value:_isNotificationOn ,
               onChanged: (newVal){
                 _isNotificationOn= newVal;
                 if(newVal == true){                 
                   _onNotification(context);
                   _checkPendingNotificationRequests();
                 }
                 if (newVal ==false){
                   _cancelAllNotifications();
                 }
               },
             ),   
            TimeTableDisplay(),
          ],
        ),
      ),
    );
  }
}

 Future<void> _showNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
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


 Future<void> _showWeeklyAtDayAndTime(int hr ,Day day, String course,int id) async {
    var time = Time(hr-1, 50, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'show weekly channel id',
        'show weekly channel name',
        'show weekly description');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        id,
        course,
        'Class in 10 min',
        day,
        time,
        platformChannelSpecifics);
  }

  void _onNotification(BuildContext context){
    final items= Provider.of<TTProvider>(context).items;
   [...items].forEach((slot){
      if(slot.mon != ""){
        _showWeeklyAtDayAndTime(slot.hr, Day.Monday,slot.mon,slot.hr*10+1);
      }
      if(slot.tue != ""){
        _showWeeklyAtDayAndTime(slot.hr, Day.Tuesday,slot.tue,slot.hr*10+2);
      }
      if(slot.wed != ""){
        _showWeeklyAtDayAndTime(slot.hr, Day.Wednesday,slot.wed,slot.hr*10+3);
      }
      if(slot.thu != ""){
        _showWeeklyAtDayAndTime(slot.hr, Day.Thursday,slot.thu,slot.hr*10+4);
      }
      if(slot.fri != ""){
        _showWeeklyAtDayAndTime(slot.hr, Day.Friday,slot.fri,slot.hr*10+5);
      }
      if(slot.sat != ""){
        _showWeeklyAtDayAndTime(slot.hr, Day.Saturday,slot.sat,slot.hr*10+6);
      }
    });
  }

class TimeTableDisplay extends StatelessWidget {
  const TimeTableDisplay({
    Key key,
  }) : super(key: key);

  void modifySlotDialog(BuildContext context, int hr, String column) {
    final _slotController = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('Modify slot'),
              content: TextField(
                decoration: InputDecoration(labelText: 'Enter Course'),
                controller: _slotController,
                onSubmitted: (_) {},
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('NO'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                    child: Text('YES'),
                    onPressed: () {
                      Provider.of<TTProvider>(context)
                          .updateSlot(hr, column, _slotController.text);
                      Navigator.of(context).pop();
                    })
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<TTProvider>(context).fetchAndSetSlot(),
      builder: (ctx, snapshot) => Consumer<TTProvider>(
        builder: (context, ttVal, _) =>  SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('time')),
                DataColumn(label: Text('Monday')),
                DataColumn(label: Text('Tuesday')),
                DataColumn(label: Text('Wednesday')),
                DataColumn(label: Text('Thursday')),
                DataColumn(label: Text('Friday')),
                DataColumn(label: Text('Saturday')),
              ],
              rows: ttVal.items
                  .map((item) => DataRow(cells: [
                        DataCell(Text('${item.hr}')),
                        DataCell(Text(item.mon),
                            
                            onTap: () =>
                                modifySlotDialog(context, item.hr, 'mon')),
                        DataCell(Text(item.tue),
                            
                            onTap: () =>
                                modifySlotDialog(context, item.hr, 'tue')),
                        DataCell(Text(item.wed),
                            
                            onTap: () =>
                                modifySlotDialog(context, item.hr, 'wed')),
                        DataCell(Text(item.thu),
                            
                            onTap: () =>
                                modifySlotDialog(context, item.hr, 'thu')),
                        DataCell(Text(item.fri),
                            
                            onTap: () =>
                                modifySlotDialog(context, item.hr, 'fri')),
                        DataCell(Text(item.sat),
                            
                            onTap: () =>
                                modifySlotDialog(context, item.hr, 'sat')),
                      ]))
                  .toList(),
            ),
          ),
        ),
      
    );
  }
}
