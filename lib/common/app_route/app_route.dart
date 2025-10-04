import 'package:ecom_task/common/app_route/app_route_name.dart';
import 'package:ecom_task/screens/bottom_nav_screen/bottom_nav_screen.dart';
import 'package:ecom_task/screens/payment_screen/ui/payment_screen.dart';
import 'package:ecom_task/screens/payment_sucess_screen/payment_success_screen.dart';
import 'package:ecom_task/screens/product_detail_view/product_detail_view.dart';
import 'package:ecom_task/screens/product_view/ui/product_view.dart';
import 'package:get/get.dart';
class AppRouteScreen {
  static final routes = [
    GetPage(
      name: AppRoutes.bnb,
      page: () => BottomNavBarScreen(),
    ),
    GetPage(
      name: AppRoutes.productView,
      page: () => ProductView(),
    ),
    GetPage(
      name: AppRoutes.productDetailView,
      page: () => ProductDetailView(),
    ),
    GetPage(
      name: AppRoutes.paymentScreen,
      page: () => PaymentScreen(),
    ),
    GetPage(
      name: AppRoutes.successScreen,
      page: () => SuccessScreen(),
    ),
  ];
}
