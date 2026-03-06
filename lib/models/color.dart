import 'package:flutter/material.dart';

class MyColor extends ChangeNotifier {
  final Color item = Color(0xFFFAFAFA);
  
  final Color grey = Color(0xFFEBEBEB);

  final Color cal_grey = Color(0xFFF1F1F1);

  final Color item_grey = Color(0xFFEDEDED);
  
  final Color barGrey = Color(0xFFDCDCDC);

  final Color hint = Color(0xFFB7B7B7);

  final Color hint2 = Color(0xFF9F9F9F);

  final Color text = Color(0xFF909090);
  
  final Color red = Color(0xFFF54040);

  final List<Color> cal_red = [Color(0xFFFFEBEE), Color(0xFFE57373), Color(0xFFF44336), Color(0xFFC62828)];

  final List<Color> cal_green = [Color(0xFFE8F5E9), Color(0xFF81C784), Color(0xFF4CAF50), Color(0xFF2E7D32)];
}