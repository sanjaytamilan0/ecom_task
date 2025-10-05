import 'package:ecom_task/common/app_colors/app_colors.dart';
import 'package:ecom_task/screens/product_view/model/product_model.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onLikeToggle;
  final VoidCallback onAddToCart;
  final VoidCallback cardClick;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const ProductCard({
    required this.product,
    required this.onLikeToggle,
    required this.onAddToCart,
    required this.cardClick,
    this.onIncrement,
    this.onDecrement,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: cardClick,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: Colors.grey.withOpacity(0.25),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Row(
            children: [
              // ---------- PRODUCT IMAGE ----------
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.image,
                  height: 110,
                  width: 110,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 110,
                      width: 110,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 16),

              // ---------- PRODUCT INFO ----------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Text(
                          "₹ ${product.price.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColor().primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ---------- LIKE BUTTON ----------
                        InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: onLikeToggle,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: product.isLiked ? Colors.red.shade50 : Colors.grey.shade200,
                            ),
                            child: Icon(
                              product.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: product.isLiked ? Colors.red : Colors.grey.shade600,
                              size: 22,
                            ),
                          ),
                        ),

                        // ---------- CART ACTION BUTTON ----------
                        if (product.cartQuantity == 0)
                          ElevatedButton(
                            onPressed: onAddToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor().primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              "Buy Now",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColor().white,
                              ),
                            ),
                          )
                        else
                          Row(
                            children: [
                              IconButton(
                                onPressed: onDecrement,
                                icon: Icon(Icons.remove_circle_outline, color: AppColor().primaryColor),
                              ),
                              Text(
                                product.cartQuantity.toString(),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              IconButton(
                                onPressed: onIncrement,
                                icon: Icon(Icons.add_circle_outline, color: AppColor().primaryColor),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
