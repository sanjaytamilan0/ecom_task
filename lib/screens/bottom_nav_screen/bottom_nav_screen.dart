import 'package:ecom_task/common/app_colors/app_colors.dart';
import 'package:ecom_task/common/app_route/app_route_name.dart';
import 'package:ecom_task/screens/cart_screen/ui/cart_screen.dart';
import 'package:ecom_task/screens/order_screen/ui/order_screen.dart';
import 'package:ecom_task/screens/product_detail_view/product_detail_view.dart';
import 'package:ecom_task/screens/product_view/ui/product_view.dart';
import 'package:ecom_task/screens/wishlist_screen/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavBarScreen extends StatefulWidget {
  @override
  _BottomNavBarScreenState createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ProductView(),
    CartScreen(),
    OrderListScreen(),
    WishlistScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor().white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColor().white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColor().primaryColor,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_cart,
              color: _selectedIndex == 1 ? AppColor().primaryColor : AppColor().black,
            ),
            label: 'cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt_long,
              color: _selectedIndex == 2 ? AppColor().primaryColor : AppColor().black,
            ),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_border,
              color: _selectedIndex == 3 ? AppColor().primaryColor : AppColor().black,
            ),
            label: 'wishlist',
          ),
        ],

      ),

    );
  }
}
