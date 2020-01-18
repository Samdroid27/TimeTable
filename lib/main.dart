import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/tt_screen.dart';
import './providers/tt_provider.dart';

void main()=> runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value:TTProvider() ,
          child: MaterialApp(
        home: TTScreen()
      ),
    );
  }
}



