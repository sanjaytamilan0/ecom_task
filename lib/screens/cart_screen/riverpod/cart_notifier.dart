import 'package:ecom_task/screens/cart_screen/model/cart_model.dart';
import 'package:ecom_task/screens/product_view/model/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecom_task/common/service/local_storage/sqf_lite.dart';
import 'package:flutter_riverpod/legacy.dart';

class CartState {
  final List<CartItem> cartItems;
  final double totalPrice;

  CartState({
    required this.cartItems,
    required this.totalPrice,
  });

  factory CartState.initial() {
    return CartState(cartItems: [], totalPrice: 0);
  }

  CartState copyWith({
    List<CartItem>? cartItems,
    double? totalPrice,
  }) {
    return CartState(
      cartItems: cartItems ?? this.cartItems,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState.initial()) {
    loadCart();
  }

  Future<void> loadCart() async {
    final cartMaps = await ProductDatabase.instance.getAllCartItems();
    final cartItems = cartMaps.map((e) => CartItem.fromMap(e)).toList();
    final total = _calculateTotal(cartItems);

    state = state.copyWith(cartItems: cartItems, totalPrice: total);
  }

  double _calculateTotal(List<CartItem> items) {
    double total = 0;
    for (var item in items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  Future<void> addToCart(ProductModel product) async {
    await ProductDatabase.instance.addOrUpdateCartItem(product);
    await loadCart();
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
  return CartNotifier();
});
