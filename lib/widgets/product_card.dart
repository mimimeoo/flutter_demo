import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../models/cart_model.dart'; // Đã thêm Import CartModel mới
import '../providers/favorite_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../screens/login_screen.dart';
import '../screens/product_detail_screen.dart'; 

// -----------------------------------------------------------------------------
// 1. THẺ SẢN PHẨM DỌC (UI Minimalist)
// -----------------------------------------------------------------------------
class ProductCardVertical extends StatefulWidget {
  final ProductModel product;
  final double? width;

  const ProductCardVertical({super.key, required this.product, this.width});

  @override
  State<ProductCardVertical> createState() => _ProductCardVerticalState();
}

class _ProductCardVerticalState extends State<ProductCardVertical> with SingleTickerProviderStateMixin {
  late AnimationController _favController;

  @override
  void initState() {
    super.initState();
    _favController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.8,
      upperBound: 1.0,
    );
    _favController.value = 1.0;
  }

  @override
  void dispose() {
    _favController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoriteProvider>();
    final isFavorite = favProvider.isExist(widget.product);

    return GestureDetector(
      // BẤM VÀO THẺ MỞ TRANG CHI TIẾT
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: widget.product),
          ),
        );
      },
      child: Container(
        width: widget.width,
        margin: widget.width != null 
            ? const EdgeInsets.only(right: 12, bottom: 10) 
            : const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PHẦN HÌNH ẢNH: Edge-to-edge
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: widget.product.imageUrl.startsWith('http')
                        ? Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.cover, 
                            errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey),
                          )
                        : Image.asset(
                            widget.product.imageUrl,
                            fit: BoxFit.cover, 
                          ),
                  ),
                  // Nút Trái tim 
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        if (!context.read<AuthProvider>().isLoggedIn) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                          return;
                        }
                        _favController.reverse().then((value) => _favController.forward());
                        favProvider.toggleFavorite(widget.product);
                      },
                      child: ScaleTransition(
                        scale: _favController,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFavorite ? const Color(0xFFFA5151) : Colors.white,
                            size: 26,
                            shadows: const [
                              Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // PHẦN THÔNG TIN TỐI GIẢN
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700, 
                      fontSize: 15, 
                      color: Color(0xFF1A1D26) 
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product.formattedPrice,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFFAAC48F), 
                          fontSize: 16
                        ),
                      ),
                      _buildAddButton(context),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Nút Thêm vào giỏ hàng
  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!context.read<AuthProvider>().isLoggedIn) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          return;
        }

        // TẠO MÓN MẶC ĐỊNH VÀO GIỎ HÀNG (Size S)
        final defaultCartItem = CartItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(), 
          product: widget.product,
          quantity: 1,
          selectedSize: 'Size S',
          selectedIce: 'Đá vừa',
          selectedSweetness: '70% đường',
          selectedToppings: [],
          itemPrice: widget.product.price.toDouble(), // Giá gốc
        );

        context.read<CartProvider>().addItem(defaultCartItem);

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm ${widget.product.name} (Size S) vào giỏ!'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 700),
            backgroundColor: const Color(0xFFAAC48F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFAAC48F), 
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. THẺ SẢN PHẨM NGANG (UI Minimalist)
// -----------------------------------------------------------------------------
class ProductCardHorizontal extends StatelessWidget {
  final ProductModel product;
  const ProductCardHorizontal({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // BẤM VÀO THẺ MỞ TRANG CHI TIẾT
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        height: 110,
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            ),
          ],
        ),
        child: Row(
          children: [
            // Ảnh lấp đầy bên trái
            SizedBox(
              width: 110,
              height: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: product.imageUrl.startsWith('http')
                    ? Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image))
                    : Image.asset(product.imageUrl, fit: BoxFit.cover),
              ),
            ),
            
            // Text bên phải
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name, 
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1A1D26)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.formattedPrice, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFAAC48F))
                        ),
                        // Nút Add to Cart
                        GestureDetector(
                          onTap: () {
                            if (!context.read<AuthProvider>().isLoggedIn) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                              return;
                            }
                            
                            // TẠO MÓN MẶC ĐỊNH VÀO GIỎ HÀNG (Size S)
                            final defaultCartItem = CartItemModel(
                              id: DateTime.now().millisecondsSinceEpoch.toString(), 
                              product: product,
                              quantity: 1,
                              selectedSize: 'Size S',
                              selectedIce: 'Đá vừa',
                              selectedSweetness: '70% đường',
                              selectedToppings: [],
                              itemPrice: product.price.toDouble(), // Giá gốc
                            );

                            context.read<CartProvider>().addItem(defaultCartItem);

                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã thêm ${product.name} (Size S) vào giỏ!'),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(milliseconds: 700),
                                backgroundColor: const Color(0xFFAAC48F),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFAAC48F),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}