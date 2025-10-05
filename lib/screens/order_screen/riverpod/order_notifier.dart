import 'package:ecom_task/screens/cart_screen/riverpod/cart_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecom_task/common/service/local_storage/sqf_lite.dart';
import 'package:ecom_task/screens/cart_screen/model/cart_model.dart';
import 'package:ecom_task/screens/order_screen/model/order_model.dart';
import 'package:flutter_riverpod/legacy.dart';

class OrderState {
  final bool isLoading;
  final List<OrderModel> orders;
  final String? error;

  OrderState({
    required this.isLoading,
    required this.orders,
    this.error,
  });

  factory OrderState.initial() {
    return OrderState(isLoading: false, orders: [], error: null);
  }

  OrderState copyWith({
    bool? isLoading,
    List<OrderModel>? orders,
    String? error,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      error: error,
    );
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(ref);
});

class OrderNotifier extends StateNotifier<OrderState> {
  final Ref ref;

  OrderNotifier(this.ref) : super(OrderState.initial()){
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final orders = await ProductDatabase.instance.getAllOrders();
      state = state.copyWith(isLoading: false, orders: orders);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
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
