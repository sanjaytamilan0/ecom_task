import 'package:ecom_task/common/app_route/app_route_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text("Payment Successful!", style: TextStyle(fontSize: 20)),
            ElevatedButton(
              onPressed: () {
                Get.offNamed(AppRoutes.bnb);
              },
              child: Text("Back to Home"),
            )
          ],
        ),
      ),
    );
  }
}
