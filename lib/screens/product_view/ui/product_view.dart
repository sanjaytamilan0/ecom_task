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
      ref.read(productProvider.notifier).getProduct();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);
    final notifier = ref.read(productProvider.notifier);

    return Scaffold(
      backgroundColor: AppColor().bgColor,
      appBar: AppBar(

        backgroundColor: AppColor().primaryColor,
        title:  Text('Products',style: TextStyle(color: AppColor().white),),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for products...',
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
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.error != null) {
                  return Center(
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (state.productData == null || state.productData!.isEmpty) {
                  return const Center(child: Text('No product found'));
                }

                return ListView.builder(
                  itemCount: state.productData!.length,
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
                        ref.read(cartProvider.notifier).addToCart(data, data.cartQuantity + 1);
                      },
                      onDecrement: () {
                        if (data.cartQuantity > 1) {
                          ref.read(cartProvider.notifier).addToCart(data, data.cartQuantity - 1);
                        } else {
                          ref.read(cartProvider.notifier).removeItem(data.id);
                        }
                      },
                      cardClick: () {
                        Get.toNamed(AppRoutes.productDetailView, arguments: {
                          "product": data,
                        });
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
