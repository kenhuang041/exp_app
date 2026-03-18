/// 設定頁：預留頁面，尚未實作主題、匯出、關於等設定項（目前為佔位內容）
import 'package:exp02/models/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MySettingPage extends StatefulWidget {
  const MySettingPage({super.key});

  @override
  State<MySettingPage> createState() => _MySettingPageState();
}

class _MySettingPageState extends State<MySettingPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColor = Provider.of<MyColor>(context);

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20, top: 90),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 45,
            width: 370,
            decoration: BoxDecoration(
              color: myColor.item,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.only(left: 17, right: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("目標金額", style: TextStyle(color: Colors.black87, fontSize: 16),),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 30,
                      alignment: Alignment.centerRight,
                      child: TextField(
                        controller: _controller,
                        textAlign: TextAlign.end,
                        cursorColor: Colors.grey,
                        style: TextStyle(color: Colors.black54,),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: "尚未設置 ",
                          hintStyle: TextStyle(color: myColor.hint, fontSize: 14,),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onEditingComplete: () {

                          FocusScope.of(context).unfocus(); // 收起鍵盤
                        },
                        onTapOutside: (event) {

                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 6,),
          Container(
            alignment: AlignmentDirectional.centerStart,
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              "看你每週想存到多少錢^^",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),

          SizedBox(height: 30,),

          Container(
            height: 151,
            width: 370,
            decoration: BoxDecoration(
              color: myColor.item,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.only(left: 17, right: 17),
            child: Column(
              children: [
                SizedBox(height: 11,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("每週固定收入", style: TextStyle(color: Colors.black87, fontSize: 16),),
                    Container(
                      width: 100,
                      height: 30,
                      alignment: Alignment.centerRight,
                      child: TextField(
                        controller: _controller2,
                        textAlign: TextAlign.end,
                        cursorColor: Colors.grey,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(color: Colors.black54,),
                        decoration: InputDecoration(
                          hintText: "尚未設置 ",
                          hintStyle: TextStyle(color: myColor.hint, fontSize: 14,),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onEditingComplete: () {
                          FocusScope.of(context).unfocus(); // 收起鍵盤
                        },
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: 360,
                    height: 0.4,
                    color: myColor.hint,
                  ),
                ),

                SizedBox(height: 12,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("標籤管理", style: TextStyle(color: Colors.black87, fontSize: 16),),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: myColor.hint,)
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: 360,
                    height: 0.4,
                    color: myColor.hint,
                  ),
                ),

                SizedBox(height: 12,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("預設輸入項目名稱", style: TextStyle(color: Colors.black87, fontSize: 16),),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: myColor.hint,)
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
