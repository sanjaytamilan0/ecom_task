import 'package:ecom_task/models/cart_model.dart';
import 'package:ecom_task/models/product_model.dart';
import 'package:ecom_task/screens/product_view/riverpod/product_notifier.dart';
import 'package:ecom_task/service/local_storage/sqf_lite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class CartState {
  final List<CartItem> cartItems;
  final double totalPrice;
  final bool isLoading;

  CartState({
    required this.cartItems,
    required this.totalPrice,
    required this.isLoading,
  });

  factory CartState.initial() {
    return CartState(
      cartItems: [],
      totalPrice: 0,
      isLoading: false,
    );
  }

  CartState copyWith({
    List<CartItem>? cartItems,
    double? totalPrice,
    bool? isLoading,
  }) {
    return CartState(
      cartItems: cartItems ?? this.cartItems,
      totalPrice: totalPrice ?? this.totalPrice,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final Ref ref;
  CartNotifier(this.ref) : super(CartState.initial()) {
    loadCart();
  }
  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true);

    final cartMaps = await ProductDatabase.instance.getAllCartItems();
    final cartItems = cartMaps.map((e) => CartItem.fromMap(e)).toList();
    final total = _calculateTotal(cartItems);

    state = state.copyWith(cartItems: cartItems, totalPrice: total, isLoading: false);
  }


  double _calculateTotal(List<CartItem> items) {
    double total = 0;
    for (var item in items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  Future<void> addToCart(ProductModel product, int quantity) async {
    await ProductDatabase.instance.addOrUpdateCartItem(product, quantity);
    await Future.wait([
      loadCart(),
      ref.read(productProvider.notifier).addToCartFromProduct(),
    ]);
  }


  Future<void> incrementQuantity(int productId) async {
    final currentItem = state.cartItems.firstWhere((e) => e.productId == productId);
    await ProductDatabase.instance.updateCartItemQuantity(productId, currentItem.quantity + 1);
    await loadCart();
  }

  Future<void> decrementQuantity(int productId) async {
    final currentItem = state.cartItems.firstWhere((e) => e.productId == productId);
    final newQuantity = currentItem.quantity - 1;
    if (newQuantity <= 0) {
      await ProductDatabase.instance.removeCartItem(productId);
    } else {
      await ProductDatabase.instance.updateCartItemQuantity(productId, newQuantity);
    }
    await loadCart();
  }

  Future<void> removeItem(int productId) async {
    await ProductDatabase.instance.removeCartItem(productId);
    await loadCart();
  }

  Future<void> clearCart() async {
    await ProductDatabase.instance.clearCart();
    await loadCart();
  }

}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref);
});
