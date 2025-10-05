class CartItem {
  final int productId;
  final String title;
  final double price;
  final int quantity;
  final String image;

  CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.image,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      title: title,
      price: price,
      quantity: quantity ?? this.quantity,
      image: image,
    );
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'],
      title: map['title'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'],
      image: map['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }
}
