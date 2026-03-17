/// 全域 UI 色彩定義（背景、文字、提示、日曆色階等）
///
/// 繼承 [ChangeNotifier] 可於日後擴充主題切換時呼叫 notifyListeners。

import 'package:flutter/material.dart';

class MyColor extends ChangeNotifier {
  final Color item = Color(0xFFFAFAFA);
  final Color grey = Color(0xFFEBEBEB);
  final Color cal_grey = Color(0xFFF1F1F1);
  final Color any_item = Color(0xFFF4F4F4);
  final Color item_grey = Color(0xFFEDEDED);
  final Color barGrey = Color(0xFFDCDCDC);
  final Color hint = Color(0xFFB7B7B7);
  final Color hint2 = Color(0xFF9F9F9F);
  final Color text = Color(0xFF909090);
  final Color barGrey2 = Color(0xFF616161);
  final Color red = Color(0xFFE57373);
  final Color blue = Color(0xFF64b5f6);

  /// 日曆支出色階（淺→深）
  final List<Color> cal_red = [Color(0xFFffcdd2), Color(0xFFef9a9a), Color(0xFFe57373), Color(0xFFef5350)];
  /// 日曆收入色階（淺→深）
  final List<Color> cal_green = [Color(0xFFc8e6c9), Color(0xFFa5d6a7), Color(0xFF81c784), Color(0xFF66bb6a)];

  // final List<Color> cal_red = [Color(0xFFFFEBEE), Color(0xFFE57373), Color(0xFFF44336), Color(0xFFC62828)];
  // final List<Color> cal_green = [Color(0xFFE8F5E9), Color(0xFF81C784), Color(0xFF4CAF50), Color(0xFF2E7D32)];
}