import 'package:ecom_task/common/app_colors/app_colors.dart';
import 'package:ecom_task/common/widgets/common_app_bar/common_app_bar.dart';
import 'package:ecom_task/common/widgets/dialog_box/dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ecom_task/common/app_route/app_route_name.dart';
import 'package:ecom_task/screens/cart_screen/riverpod/cart_notifier.dart';
import 'package:ecom_task/screens/order_screen/riverpod/order_notifier.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _payNow() async {
    final cartState = ref.watch(cartProvider);
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);

      await ref.read(orderProvider.notifier).placeOrder(
        cartItems: cartState.cartItems,
        cardNumber: _cardNumberController.text,
        cardHolder: _nameController.text,
        total: cartState.totalPrice,
      );ResponseDialog.showStatusDialog(
        ResponseDialog.success,
        "Thank you, ${_nameController.text}! Your order has been placed successfully.",
      );

      ref.read(cartProvider.notifier).clearCart();
      Get.offAllNamed(AppRoutes.successScreen);

      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    InputDecoration _inputDecoration(String label, {String? hint, IconData? icon}) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: AppColor().liteBlue,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.black26,
            width: 1.0,
          ),
        ),

      );
    }

    return Scaffold(
      backgroundColor: AppColor().bgColor,
      appBar: CustomAppBar(title: "Payment Details",showLeading: true,),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Credit / Debit Card",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      _cardNumberController.text.isEmpty
                          ? "XXXX XXXX XXXX XXXX"
                          : _cardNumberController.text.replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} "),
                      style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Card Holder", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(
                              _nameController.text.isEmpty ? "FULL NAME" : _nameController.text.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Expiry", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(
                              _expiryController.text.isEmpty ? "MM/YY" : _expiryController.text,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10,),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: _inputDecoration("Card Number", hint: "1234 5678 9012 3456", icon: Icons.credit_card),
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) {
                        if (val == null || val.length != 16) return "Enter a valid 16-digit card number";
                        return null;
                      },
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryController,
                            decoration: _inputDecoration("Expiry Date", hint: "MM/YY", icon: Icons.calendar_month),
                            keyboardType: TextInputType.datetime,
                            inputFormatters: [ExpiryDateTextInputFormatter()],
                            validator: (val) {
                              if (val == null || !RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(val)) {
                                return "Invalid expiry";
                              }
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            decoration: _inputDecoration("CVV", hint: "123", icon: Icons.lock),
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            obscureText: true,
                            validator: (val) {
                              if (val == null || val.length != 3) return "Enter valid CVV";
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration("Card Holder Name", icon: Icons.person),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return "Enter cardholder name";
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text("Total:", style: TextStyle(fontSize: 18)),
                const Spacer(),
                Text(
                  '₹ ${cartState.totalPrice.toStringAsFixed(2)}',
                  style:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:  AppColor().primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isProcessing ? null : _payNow,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColor().primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isProcessing
                  ? ResponseDialog.loader
                  :  Text("Pay Now", style: TextStyle(fontSize: 16,color: AppColor().white)),
            ),
          ],
        ),
      ),
    );
  }
}


class ExpiryDateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text;

    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    String formatted = '';
    if (text.length >= 3) {
      formatted = '${text.substring(0, 2)}/${text.substring(2)}';
    } else if (text.length >= 1) {
      formatted = text;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
