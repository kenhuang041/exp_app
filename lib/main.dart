/// 記帳 App 主程式入口與主框架
///
/// 負責：Flutter 綁定、Provider 注入、MaterialApp 與底部導航主頁。

import 'package:exp02/database/expense_provider.dart';
import 'package:exp02/models/color.dart';
import 'package:exp02/models/page.dart';
import 'package:exp02/pages/analysis_page.dart';
import 'package:exp02/pages/calendar_page.dart';
import 'package:exp02/pages/home_page.dart';
import 'package:exp02/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 應用程式進入點：初始化 Flutter 綁定後啟動 [MyApp]。
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// 根 Widget：註冊全域狀態（主題色、支出資料）並建立 [MaterialApp]。
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyColor()),
        ChangeNotifierProvider(create: (_) => PageIndex()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: const MaterialApp( //1212
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      ),
    );
  }
}

/// 主頁：包含四個子頁面（首頁／日曆／統計／設定）與自訂底部導航列。
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// 四個分頁：首頁記帳、日曆、統計、設定
  final List _pages = [MyExpensePage(), MyCalendarPage(), MyAnalysisPage(), MySettingPage()];
  /// 目前選中的 Tab 索引（0=首頁, 1=日曆, 2=統計, 3=設定）

  @override
  Widget build(BuildContext context) {
    var my_color = Provider.of<MyColor>(context);
    var provider = Provider.of<PageIndex>(context);
    var now = provider.currentPageIndex;

    return Scaffold(
      backgroundColor: my_color.grey,
      extendBody: true,
      // [!AI] 改用 IndexedStack：切換 Tab 時保留各頁 State，避免日曆/首頁每次切換都重跑 initState 造成重載與卡頓
      body: _pages[now],

      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: my_color.item,
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 首頁 Tab
                GestureDetector(
                  onTap: () {
                    setState(() {
                      provider.setIndex(0);
                    });
                  },
                  child: Column(
                    children: [
                      Icon(Icons.home, size: 24, color: (now == 0) ? Colors.black87 : my_color.hint2),
                      SizedBox(height: 2,),
                      Text("首頁", style: TextStyle(fontSize: 12, color: (now == 0) ? Colors.black87 : my_color.hint2),)
                    ],
                  ),
                ),
                SizedBox(width: 25,),
                // 日曆 Tab
                GestureDetector(
                  onTap: () {
                    setState(() {
                      provider.setIndex(1);
                    });
                  },
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today, size: 24, color: (now == 1) ? Colors.black87 : my_color.hint2),
                      SizedBox(height: 2,),
                      Text("日曆", style: TextStyle(fontSize: 12, color: (now == 1) ? Colors.black87 : my_color.hint2),)
                    ],
                  ),
                ),
                SizedBox(width: 25,),
                // 統計 Tab
                GestureDetector(
                  onTap: () {
                    setState(() {
                      provider.setIndex(2);
                    });
                  },
                  child: Column(
                    children: [
                      Icon(Icons.analytics, size: 24, color: (now == 2) ? Colors.black87 : my_color.hint2),
                      SizedBox(height: 2,),
                      Text("統計", style: TextStyle(fontSize: 12, color: (now == 2) ? Colors.black87 : my_color.hint2),)
                    ],
                  ),
                ),
                SizedBox(width: 25,),
                // 設定 Tab
                GestureDetector(
                  onTap: () {
                    setState(() {
                      provider.setIndex(3);
                    });
                  },
                  child: Column(
                    children: [
                      Icon(Icons.settings, size: 24, color: (now == 3) ? Colors.black87 : my_color.hint2),
                      SizedBox(height: 2,),
                      Text("設定", style: TextStyle(fontSize: 12, color: (now == 3) ? Colors.black87 : my_color.hint2),)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
