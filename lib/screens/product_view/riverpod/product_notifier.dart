import 'dart:async';

import 'package:ecom_task/common/service/local_storage/sqf_lite.dart';
import 'package:ecom_task/common/service/repo/repo.dart';
import 'package:ecom_task/screens/product_view/model/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
class ProductState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final String? message;
  final List<ProductModel>? productData;
  final List<ProductModel>? likedProducts; // New field for liked products
  final String search;

  ProductState({
    required this.isLoading,
    this.error,
    required this.isSuccess,
    this.message,
    this.productData,
    this.likedProducts, // add this param
    this.search = '',
  });

  factory ProductState.initial() {
    return ProductState(
      isLoading: false,
      isSuccess: false,
      likedProducts: [], // initialize likedProducts as empty list
    );
  }

  ProductState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    String? message,
    List<ProductModel>? productData,
    List<ProductModel>? likedProducts,
    String? search,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      message: message ?? this.message,
      productData: productData ?? this.productData,
      likedProducts: likedProducts ?? this.likedProducts,
      search: search ?? this.search,
    );
  }
}



class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier() : super(ProductState.initial());
  Timer? _debounce;

  Future<void> getProduct() async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final response = await Repo().getProduct();

      final List<ProductModel> apiProducts = (response as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
      final List<ProductModel> localProducts = await ProductDatabase.instance.getAllProducts();
      final mergedProducts = apiProducts.map((apiProd) {
        final localProd = localProducts.firstWhere(
              (localProd) => localProd.id == apiProd.id,
          orElse: () => apiProd,
        );
        return apiProd.copyWith(isLiked: localProd.isLiked);
      }).toList();
      await ProductDatabase.instance.insertProducts(mergedProducts);

      final likedList = mergedProducts.where((product) => product.isLiked).toList();

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        productData: mergedProducts,
        likedProducts: likedList,
      );
    } catch (error) {
      print("API failed, trying local DB...");
      final localData = await ProductDatabase.instance.getAllProducts();

      final likedList = localData.where((product) => product.isLiked).toList();

      state = state.copyWith(
        isLoading: false,
        productData: localData,
        likedProducts: likedList,
        error: error.toString(),
      );
    }
  }


  Future<void> toggleLike(int productId) async {
    final currentList = state.productData ?? [];

    final updatedList = currentList.map((product) {
      if (product.id == productId) {
        final updatedProduct = product.copyWith(isLiked: !product.isLiked);
        ProductDatabase.instance.updateProductLike(productId, updatedProduct.isLiked);
        return updatedProduct;
      }
      return product;
    }).toList();

    final updatedLiked = updatedList.where((product) => product.isLiked).toList();

    state = state.copyWith(
      productData: updatedList,
      likedProducts: updatedLiked,
    );
  }

  void clearSearch() async {
    final localProducts = await ProductDatabase.instance.getAllProducts();
    state = state.copyWith(
      search: '',
      productData: localProducts,
    );
  }

  void updateSearch(String query) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final allProducts = state.productData ?? [];

      if (query.isEmpty) {
        state = state.copyWith(search: '', productData: allProducts);
      } else {
        final filtered = allProducts.where((product) {
          return product.title.toLowerCase().contains(query.toLowerCase());
        }).toList();

        state = state.copyWith(search: query, productData: filtered);
      }
    });
  }


  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

}


final productProvider =
StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier();
});
