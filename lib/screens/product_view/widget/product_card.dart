import 'package:ecom_task/common/app_colors/app_colors.dart';
import 'package:ecom_task/models/product_model.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;

    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    final titleFontSize = isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);
    final priceFontSize = isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);
    final buttonFontSize = isSmallScreen ? 11.0 : (isMediumScreen ? 12.0 : 13.0);
    final iconSize = isSmallScreen ? 16.0 : (isMediumScreen ? 17.0 : 18.0);
    final cardPadding = isSmallScreen ? 6.0 : 8.0;
    final spacing = isSmallScreen ? 3.0 : 4.0;

    return GestureDetector(
      onTap: cardClick,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  width: double.infinity,
                  child: Image.network(
                    product.image,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor().primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: titleFontSize,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                    ),

                    SizedBox(height: spacing),

                    Text(
                      "₹ ${product.price.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: priceFontSize,
                        color: AppColor().primaryColor,
                      ),
                    ),

                    SizedBox(height: spacing + 2),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: onLikeToggle,
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 5 : 6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: product.isLiked
                                  ? Colors.red.shade50
                                  : Colors.grey.shade200,
                            ),
                            child: Icon(
                              product.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: product.isLiked
                                  ? Colors.red
                                  : Colors.grey.shade600,
                              size: iconSize,
                            ),
                          ),
                        ),

                        Flexible(
                          child: product.cartQuantity == 0
                              ? ElevatedButton(
                            onPressed: onAddToCart,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 10 : 12,
                                vertical: isSmallScreen ? 3 : 4,
                              ),
                              backgroundColor: AppColor().primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Add",
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                color: AppColor().white,
                              ),
                            ),
                          )
                              : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: onDecrement,
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    isSmallScreen ? 2 : 4,
                                  ),
                                  child: Icon(
                                    Icons.remove_circle_outline,
                                    color: AppColor().primaryColor,
                                    size: iconSize + 2,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 4 : 6,
                                ),
                                child: Text(
                                  product.cartQuantity.toString(),
                                  style: TextStyle(
                                    fontSize: buttonFontSize + 1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: onIncrement,
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    isSmallScreen ? 2 : 4,
                                  ),
                                  child: Icon(
                                    Icons.add_circle_outline,
                                    color: AppColor().primaryColor,
                                    size: iconSize + 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}