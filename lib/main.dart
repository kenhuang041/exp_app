import 'package:exp02/database/expense_provider.dart';
import 'package:exp02/models/color.dart';
import 'package:exp02/pages/analysis_page.dart';
import 'package:exp02/pages/calendar_page.dart';
import 'package:exp02/pages/home_page.dart';
import 'package:exp02/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // 尺寸適配套件

  // 寫 sqfile
  // sql: 擷取當前月份 新增一個有 31 項的 Item (每天)
  // Item (每天): 收入List, 支出List, 日期
  // List 項目 class: 項目名稱, 金額, 資金類別(收入 or 支出), 類別(tags), DateTime,

  // 寫 list 和 統計用 func()
  // 資料連結 UI

  // UI 完善
  // 可以統計總金額
  // List 新增滑動刪除供功能
  // 提供新增資料頁面

  // 修正統計方式
  // 將資料分為收入和輸出

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyColor()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List _pages = [MyExpensePage(), MyCalendarPage(), MyAnalysisPage(), MySettingPage()];
  int now = 0;

  @override
  Widget build(BuildContext context) {
    var my_color = Provider.of<MyColor>(context);

    return Scaffold(
      backgroundColor: my_color.grey,
      extendBody: true,
      body: _pages[now],

      bottomNavigationBar: Container(
        // 這裡放入你自定義的底部導航欄
        height: 100,
        decoration: BoxDecoration(
          color: my_color.item,  /*.withOpacity(0.9), // 建議用一點透明度，效果更自然*/
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      now = 0;
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

                GestureDetector(
                  onTap: () {
                    setState(() {
                      now = 1;
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

                GestureDetector(
                  onTap: () {
                    setState(() {
                      now = 2;
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

                GestureDetector(
                  onTap: () {
                    setState(() {
                      now = 3;
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
