import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tt_provider.dart';

class TTScreen extends StatelessWidget {
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
      body: TimeTableDisplay(),
    );
  }
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
      future: Provider.of<TTProvider>(context).fetchAndSetPlaces(),
      builder: (ctx, snapshot) => Consumer<TTProvider>(
        builder: (context, ttVal, _) => SingleChildScrollView(
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
                          showEditIcon: true,
                          onTap: () =>
                              modifySlotDialog(context, item.hr, 'mon')),
                      DataCell(Text(item.tue),
                          showEditIcon: true,
                          onTap: () =>
                              modifySlotDialog(context, item.hr, 'tue')),
                      DataCell(Text(item.wed),
                          showEditIcon: true,
                          onTap: () =>
                              modifySlotDialog(context, item.hr, 'wed')),
                      DataCell(Text(item.thu),
                          showEditIcon: true,
                          onTap: () =>
                              modifySlotDialog(context, item.hr, 'thu')),
                      DataCell(Text(item.fri),
                          showEditIcon: true,
                          onTap: () =>
                              modifySlotDialog(context, item.hr, 'fri')),
                      DataCell(Text(item.sat),
                          showEditIcon: true,
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
