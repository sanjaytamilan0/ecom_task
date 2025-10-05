
import 'package:ecom_task/common/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResponseDialog {
  static const String success = 'success';
  static const String failed = 'failed';

  static const TextStyle whiteTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
  );

  static const TextStyle boldWhiteTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static const loader = Center(child: SizedBox(
    width: 25,
      height: 25,
      child: CircularProgressIndicator()));

  static void showStatusDialog(String status,String msg,) {
    final colors = AppColor();
    final backgroundColor = status == success ? AppColor().primaryColor : Colors.red;
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor:backgroundColor ,
      textColor: colors.white,
      fontSize: 16.0,
    );
  }

}