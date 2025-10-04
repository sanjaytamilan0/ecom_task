import 'dart:convert';
import 'package:ecom_task/screens/cart_screen/model/cart_model.dart';

class OrderModel {
  final int? id;
  final List<CartItem> cartItems; // ✅ New
  final double totalAmount;
  final String cardNumber;
  final String cardHolder;
  final String dateTime;

  OrderModel({
    this.id,
    required this.cartItems,
    required this.totalAmount,
    required this.cardNumber,
    required this.cardHolder,
    required this.dateTime,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      cartItems: (jsonDecode(json['cartItems']) as List)
          .map((item) => CartItem.fromMap(item))
          .toList(),
      totalAmount: json['totalAmount'],
      cardNumber: json['cardNumber'],
      cardHolder: json['cardHolder'],
      dateTime: json['dateTime'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cartItems': jsonEncode(cartItems.map((e) => e.toMap()).toList()),
    'totalAmount': totalAmount,
    'cardNumber': cardNumber,
    'cardHolder': cardHolder,
    'dateTime': dateTime,
  };
}
