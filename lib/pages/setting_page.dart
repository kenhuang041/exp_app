/// 設定頁：預留頁面，尚未實作主題、匯出、關於等設定項（目前為佔位內容）
import 'package:flutter/material.dart';

class MySettingPage extends StatefulWidget {
  const MySettingPage({super.key});

  @override
  State<MySettingPage> createState() => _MySettingPageState();
}

class _MySettingPageState extends State<MySettingPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("789"),
    );
  }
}
