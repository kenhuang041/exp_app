import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageIndex extends ChangeNotifier {
  int __currentPageIndex = 0;
  int get currentPageIndex => __currentPageIndex;

  void setIndex(int idx) {
    __currentPageIndex = idx;
    notifyListeners();
  }
}