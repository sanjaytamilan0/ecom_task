import 'package:ecom_task/common/service/local_storage/sqf_lite.dart';
import 'package:ecom_task/screens/cart_screen/model/cart_model.dart';
import 'package:ecom_task/screens/cart_screen/riverpod/cart_notifier.dart';
import 'package:ecom_task/screens/order_screen/model/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final orderProvider = StateNotifierProvider<OrderNotifier, List<OrderModel>>((ref) {
  return OrderNotifier(ref);
});

class OrderNotifier extends StateNotifier<List<OrderModel>> {
  final Ref ref;
  OrderNotifier(this.ref) : super([]);

  Future<void> fetchOrders() async {
    final orders = await ProductDatabase.instance.getAllOrders();
    state = orders;
  }

  Future<void> placeOrder({
    required List<CartItem> cartItems,
    required String cardNumber,
    required String cardHolder,
    required double total,
  }) async {
    final now = DateTime.now().toIso8601String();

    final order = OrderModel(
      cartItems: cartItems,
      totalAmount: total,
      cardNumber: cardNumber,
      cardHolder: cardHolder,
      dateTime: now,
    );

    await ProductDatabase.instance.addOrder(order);
    await ref.read(cartProvider.notifier).clearCart();
    await fetchOrders();
  }

}
