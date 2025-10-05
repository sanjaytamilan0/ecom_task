import 'package:ecom_task/common/app_colors/app_colors.dart';
import 'package:ecom_task/common/app_route/app_route_name.dart';
import 'package:ecom_task/common/widgets/common_app_bar/common_app_bar.dart';
import 'package:ecom_task/screens/product_view/widget/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';// your product card widget
import 'package:ecom_task/screens/product_view/riverpod/product_notifier.dart';
import 'package:get/get.dart';

import '../cart_screen/riverpod/cart_notifier.dart'; // your provider

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productProvider);
    final likedProducts = productState.likedProducts ?? [];

    if (productState.isLoading && likedProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (likedProducts.isEmpty) {
      return const Center(
        child: Text(
          'Your wishlist is empty!',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor().bgColor,
      appBar: CustomAppBar(title: "Wishlist",showLeading: false,),
      body: ListView.builder(
        itemCount: likedProducts.length,
        itemBuilder: (context, index) {
          final product = likedProducts[index];
          return ProductCard(product: product,onLikeToggle: () {
            ref.read(productProvider.notifier).toggleLike(product.id);

          },

            onAddToCart: () {
              ref.read(cartProvider.notifier).addToCart(product, 1);
            },
            onIncrement: () {
              ref.read(cartProvider.notifier).addToCart(product, product.cartQuantity + 1);
            },
            onDecrement: () {
              if (product.cartQuantity > 1) {
                ref.read(cartProvider.notifier).addToCart(product, product.cartQuantity - 1);
              } else {
                ref.read(cartProvider.notifier).removeItem(product.id);
              }
            },
            cardClick: () {
              Get.toNamed(AppRoutes.productDetailView,arguments: {
                "product":product
              });
            },
          );
        },
      ),
    );
  }
}
