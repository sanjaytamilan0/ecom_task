import 'dart:async';

import 'package:ecom_task/models/product_model.dart';
import 'package:ecom_task/service/local_storage/sqf_lite.dart';
import 'package:ecom_task/service/repo/repo.dart';
import 'package:flutter_riverpod/legacy.dart';
class ProductState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final String? message;
  final List<ProductModel>? allProducts;
  final List<ProductModel>? productData;
  final List<ProductModel>? likedProducts;
  final String search;

  ProductState({
    required this.isLoading,
    this.error,
    required this.isSuccess,
    this.message,
    this.allProducts,
    this.productData,
    this.likedProducts,
    this.search = '',
  });

  factory ProductState.initial() {
    return ProductState(
      isLoading: false,
      isSuccess: false,
      likedProducts: [],
      allProducts: [],
      productData: [],
    );
  }

  ProductState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    String? message,
    List<ProductModel>? allProducts,
    List<ProductModel>? productData,
    List<ProductModel>? likedProducts,
    String? search,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      message: message ?? this.message,
      allProducts: allProducts ?? this.allProducts,
      productData: productData ?? this.productData,
      likedProducts: likedProducts ?? this.likedProducts,
      search: search ?? this.search,
    );
  }
}



class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier() : super(ProductState.initial()){
    initFetch();
  }
  Timer? _debounce;
  Future<void> initFetch() async {
    state = state.copyWith(isLoading: true);

    try {
      final localProducts = await ProductDatabase.instance.getAllProducts();

      if (localProducts.isNotEmpty) {
        final likedList = localProducts.where((product) => product.isLiked).toList();
        final filtered = state.search.isEmpty
            ? localProducts
            : localProducts.where((product) =>
            product.title.toLowerCase().contains(state.search.toLowerCase()))
            .toList();

        state = state.copyWith(
          allProducts: localProducts,
          productData: filtered,
          likedProducts: likedList,
          isSuccess: true,
          isLoading: false,
        );
      } else {
        await getProduct();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

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
        return apiProd.copyWith(
          isLiked: localProd.isLiked,
          cartQuantity: localProd.cartQuantity,
        );
      }).toList();

      await ProductDatabase.instance.insertProducts(mergedProducts);

      final likedList = mergedProducts.where((product) => product.isLiked).toList();

      final filtered = state.search.isEmpty
          ? mergedProducts
          : mergedProducts.where((product) =>
          product.title.toLowerCase().contains(state.search.toLowerCase())
      ).toList();

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        allProducts: mergedProducts,
        productData: filtered,
        likedProducts: likedList,
      );
    } catch (error) {
      print("API failed, trying local DB...");
      final localData = await ProductDatabase.instance.getAllProducts();

      final likedList = localData.where((product) => product.isLiked).toList();

      final filtered = state.search.isEmpty
          ? localData
          : localData.where((product) =>
          product.title.toLowerCase().contains(state.search.toLowerCase())
      ).toList();

      state = state.copyWith(
        isLoading: false,
        allProducts: localData,
        productData: filtered,
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

  Future<void> addToCartFromProduct() async {

    await initFetch();
    if (state.search.isNotEmpty) {
      updateSearch(state.search);
    }
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
