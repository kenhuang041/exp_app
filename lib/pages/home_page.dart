import 'package:exp02/models/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    var my_color = Provider.of<MyColor>(context);

    return Scaffold(
      backgroundColor: my_color.grey,
      extendBody: true,
      appBar: AppBar(
        title: Text("Welcome back",style: TextStyle(fontSize: 16)),
        centerTitle: false, // 是否置中 反之向左對齊

        titleSpacing: 10,  // title 和邊緣的距離
        leadingWidth: 60,  // leading 和邊緣的距離

        backgroundColor: Colors.transparent,
        elevation: 0, // 透明度？
        scrolledUnderElevation: 0, // 防止滑動變色

        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Center(
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1000),
              ),
              child: Icon(Icons.arrow_back_ios_rounded, color: Colors.black, size: 16,),
            ),
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1000),
              ),
              child: Icon(Icons.settings, color: Colors.black, size: 20,),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 360,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            SizedBox(height: 20,),

            Container(
              width: 360,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            SizedBox(height: 20,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Transactions", style: TextStyle(fontSize: 14),),
                InkWell(
                  onTap: () {

                  },
                  child: Container(
                    width: 65,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(90),
                    ),
                    child: Center(child: Text("see all", style: TextStyle(fontSize: 14),)),
                  ),
                )
              ],
            ),

            SizedBox(height: 20,),

            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      height: 70,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text("item0${index}"),
                        subtitle: Text("this is the test of subtitle...",style: TextStyle(color: Color(
                            0xFFBBBCBC)),),
                        visualDensity: VisualDensity.compact,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: my_color.grey,
                            borderRadius: BorderRadius.circular(1000),
                          ),
                          child: Icon(Icons.arrow_upward, size: 20,),
                        ),
                      ),
                    ),
                  );
                }
              )
            )
          ],
        ),
      ),

      /*ottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: [ //底部欄位的每個項
          BottomNavigationBarItem(
              icon: Icon(Icons.home,), //圖示
              label: "Home" //文字
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.wallet,), //圖示
              label: "Wallet" //文字
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.analytics,), //圖示
              label: "Analyties" //文字
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.settings,), //圖示
              label: "Setting" //文字
          ),
        ],

        selectedItemColor: Colors.black,
      ),*/

      bottomNavigationBar: Container(
        // 這裡放入你自定義的底部導航欄
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,  /*.withOpacity(0.9), // 建議用一點透明度，效果更自然*/
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Icon(Icons.home, size: 28,),
                    Text("Home")
                  ],
                ),
                SizedBox(width: 25,),

                Column(
                  children: [
                    Icon(Icons.wallet, size: 28, color: Color(0xFF9F9F9F)),
                    Text("Wallet")
                  ],
                ),
                SizedBox(width: 25,),

                Column(
                  children: [
                    Icon(Icons.analytics, size: 28, color: Color(0xFF9F9F9F)),
                    Text("Analytics")
                  ],
                ),
                SizedBox(width: 25,),

                Column(
                  children: [
                    Icon(Icons.settings, size: 28, color: Color(0xFF9F9F9F)),
                    Text("Setting")
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}