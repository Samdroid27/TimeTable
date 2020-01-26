import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tt_provider.dart';

class TimeTableDisplay extends StatelessWidget {
  const TimeTableDisplay({
    Key key,
  }) : super(key: key);

  void modifySlotDialog(
      BuildContext context, int hr, String column, String course) {
    final _slotController = TextEditingController(text: course);
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
                          onTap: () => modifySlotDialog(
                                context,
                                item.hr,
                                'mon',
                                item.mon,
                              )),
                      DataCell(Text(item.tue),
                          onTap: () => modifySlotDialog(
                                context,
                                item.hr,
                                'tue',
                                item.tue,
                              )),
                      DataCell(Text(item.wed),
                          onTap: () => modifySlotDialog(
                                context,
                                item.hr,
                                'wed',
                                item.wed,
                              )),
                      DataCell(Text(item.thu),
                          onTap: () => modifySlotDialog(
                                context,
                                item.hr,
                                'thu',
                                item.thu,
                              )),
                      DataCell(Text(item.fri),
                          onTap: () => modifySlotDialog(
                                context,
                                item.hr,
                                'fri',
                                item.fri,
                              )),
                      DataCell(Text(item.sat),
                          onTap: () => modifySlotDialog(
                                context,
                                item.hr,
                                'sat',
                                item.sat,
                              )),
                    ]))
                .toList(),
          ),
        ),
      ),
    );
  }
}