import 'package:ecom_task/common/app_colors/app_colors.dart';
import 'package:ecom_task/common/app_route/app_route_name.dart';
import 'package:ecom_task/common/widgets/common_app_bar/common_app_bar.dart';
import 'package:ecom_task/screens/product_view/widget/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecom_task/screens/product_view/riverpod/product_notifier.dart';
import 'package:get/get.dart';
import '../cart_screen/riverpod/cart_notifier.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  int _getCrossAxisCount(double width) {
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }

  double _getChildAspectRatio(double width) {
    if (width < 360) return 0.6;
    if (width < 600) return 0.65;
    if (width < 900) return 0.7;
    return 0.75;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productProvider);
    final likedProducts = productState.likedProducts ?? [];
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor().bgColor,
      appBar: CustomAppBar(title: "Wishlist", showLeading: false),
      body: Builder(
        builder: (context) {
          if (productState.isLoading && likedProducts.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColor().primaryColor,
              ),
            );
          }

          if (likedProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty!',
                    style: TextStyle(
                      fontSize: screenWidth < 360 ? 16 : 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add products you love to your wishlist',
                    style: TextStyle(
                      fontSize: screenWidth < 360 ? 13 : 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
              final childAspectRatio = _getChildAspectRatio(constraints.maxWidth);
              final horizontalPadding = constraints.maxWidth < 360 ? 8.0 : 12.0;
              final spacing = constraints.maxWidth < 360 ? 12.0 : 16.0;

              return GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 10,
                ),
                itemCount: likedProducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  final product = likedProducts[index];
                  return ProductCard(
                    product: product,
                    onLikeToggle: () {
                      ref.read(productProvider.notifier).toggleLike(product.id);
                    },
                    onAddToCart: () {
                      ref.read(cartProvider.notifier).addToCart(product, 1);
                    },
                    onIncrement: () {
                      ref.read(cartProvider.notifier).addToCart(
                        product,
                        product.cartQuantity + 1,
                      );
                    },
                    onDecrement: () {
                      if (product.cartQuantity > 1) {
                        ref.read(cartProvider.notifier).addToCart(
                          product,
                          product.cartQuantity - 1,
                        );
                      } else {
                        ref.read(cartProvider.notifier).removeItem(product.id);
                      }
                    },
                    cardClick: () {
                      Get.toNamed(
                        AppRoutes.productDetailView,
                        arguments: {"product": product},
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}