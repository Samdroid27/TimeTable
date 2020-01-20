
import 'package:flutter/foundation.dart';

import '../helpers/db_helper.dart';
import '../models/hr_slot.dart';

class TTProvider with ChangeNotifier{
  List<HrSlot> _items =[];

  List<HrSlot> get items {
    return [..._items];
  }
   Future<void> fetchAndSetSlot() async {
    final dataList = await DBHelper.getData('tt');
    _items = dataList.map((item)=> HrSlot(
     item['hr'],
     item['mon'],
     item['tue'],
     item['wed'],
     item['thu'],
     item['fri'],
     item['sat'],
    )).toList();
    notifyListeners();
  }

  Future<void> updateSlot(int hr, String column,String course) async{
   await DBHelper.update('tt', column, course, hr);
   notifyListeners();
    
  }

}