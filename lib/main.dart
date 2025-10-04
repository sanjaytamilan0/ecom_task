import 'package:ecom_task/common/app_route/app_route.dart';
import 'package:ecom_task/common/app_route/app_route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.bnb,
        getPages: AppRouteScreen.routes,
      ),
    );
  }
}
