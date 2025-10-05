import 'package:ecom_task/common/app_colors/app_colors.dart';
import 'package:ecom_task/common/app_route/app_route_name.dart';
import 'package:ecom_task/screens/cart_screen/riverpod/cart_notifier.dart';
import 'package:ecom_task/screens/product_view/riverpod/product_notifier.dart';
import 'package:ecom_task/screens/product_view/widget/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class ProductView extends ConsumerStatefulWidget {
  const ProductView({super.key});

  @override
  ConsumerState<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends ConsumerState<ProductView> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    Future.microtask(() {
      ref.read(productProvider.notifier).initFetch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);
    final notifier = ref.read(productProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor().bgColor,
      appBar: AppBar(
        backgroundColor: AppColor().primaryColor,
        title: Text(
          'Products',
          style: TextStyle(color: AppColor().white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth < 360 ? 8.0 : 12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                hintStyle: TextStyle(
                  fontSize: screenWidth < 360 ? 13 : 14,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state.search.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    notifier.clearSearch();
                    notifier.updateSearch('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: screenWidth < 360 ? 12 : 14,
                ),
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  notifier.clearSearch();
                }
                notifier.updateSearch(value.isEmpty ? '' : value);
              },
            ),
          ),

          Expanded(
            child: Builder(
              builder: (_) {
                if ((state.productData?.isEmpty ?? true) && state.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColor().primaryColor,
                    ),
                  );
                }

                if (state.productData == null || state.productData!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No product found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
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
                      itemCount: state.productData!.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final data = state.productData![index];
                        return ProductCard(
                          product: data,
                          onLikeToggle: () {
                            ref.read(productProvider.notifier).toggleLike(data.id);
                          },
                          onAddToCart: () {
                            ref.read(cartProvider.notifier).addToCart(data, 1);
                          },
                          onIncrement: () {
                            ref.read(cartProvider.notifier).addToCart(
                              data,
                              data.cartQuantity + 1,
                            );
                          },
                          onDecrement: () {
                            if (data.cartQuantity > 1) {
                              ref.read(cartProvider.notifier).addToCart(
                                data,
                                data.cartQuantity - 1,
                              );
                            } else {
                              ref.read(cartProvider.notifier).removeItem(data.id);
                            }
                          },
                          cardClick: () {
                            Get.toNamed(
                              AppRoutes.productDetailView,
                              arguments: {
                                "product": data,
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}