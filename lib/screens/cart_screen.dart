import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 

import '../providers/cart_provider.dart';
import 'product_detail_screen.dart'; 
import 'checkout_screen.dart'; // 🔥 Import trang Thanh toán mới thêm

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  final Color _primaryColor = const Color(0xFFAAC48F); 

  String _formatCurrency(double amount) {
    final format = NumberFormat("#,##0", "vi_VN");
    return "${format.format(amount)}đ";
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items.values.toList();

    double subtotal = cart.totalAmount;
    double deliveryFee = items.isEmpty ? 0 : 15000.0; 
    double total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Icon(Icons.arrow_back, color: Colors.grey.shade500, size: 20),
              ),
            ),
            Text(
              "Giỏ hàng", 
              style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 18)
            ),
            GestureDetector(
              onTap: () => cart.clearCart(),
              child: Icon(Icons.remove_shopping_cart_outlined, color: _primaryColor, size: 24),
            )
          ],
        ),
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  Text("Giỏ hàng đang trống", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text("Hãy chọn thêm món đồ uống nhé!", style: TextStyle(color: Colors.grey.shade400)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final cartItem = items[index];
                      return _buildCartItemCard(context, cartItem, cart);
                    },
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Navigator.pop(context), 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline_rounded, color: _primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Thêm sản phẩm khác", 
                          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600, fontSize: 15)
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      bottomNavigationBar: items.isEmpty ? null : Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade100, width: 2)), 
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tạm tính:", style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                  Text(_formatCurrency(subtotal), style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Phí giao hàng:", style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                  Text(_formatCurrency(deliveryFee), style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Colors.grey.shade200),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tổng cộng:", style: TextStyle(color: _primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(_formatCurrency(total), style: TextStyle(color: _primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  // 🔥 ĐÃ CẬP NHẬT: CHUYỂN SANG TRANG THANH TOÁN
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    elevation: 0,
                  ),
                  child: const Text("Thanh toán", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, dynamic cartItem, CartProvider cart) {
    String sizeLetter = cartItem.selectedSize.replaceAll('Size ', ''); 
    String optionsText = "Size: $sizeLetter";
    if (cartItem.selectedIce.isNotEmpty) optionsText += "\n• ${cartItem.selectedIce}";
    if (cartItem.selectedSweetness.isNotEmpty) optionsText += "\n• ${cartItem.selectedSweetness}";
    if (cartItem.selectedToppings.isNotEmpty) {
      optionsText += "\n• Thêm: ${cartItem.selectedToppings.join(', ')}";
    }
    if (cartItem.note.isNotEmpty) optionsText += "\n• Ghi chú: ${cartItem.note}";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: cartItem.product),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200), 
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: cartItem.product.imageUrl.startsWith('http')
                  ? Image.network(cartItem.product.imageUrl, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildErrorImage())
                  : Image.asset(cartItem.product.imageUrl, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildErrorImage()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cartItem.product.name, 
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1D26)), 
                          maxLines: 1, overflow: TextOverflow.ellipsis
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cart.removeItem(cartItem.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã xóa khỏi giỏ hàng'),
                              duration: Duration(seconds: 1),
                            )
                          );
                        },
                        child: Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red.shade400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    optionsText, 
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _formatCurrency(cartItem.itemPrice * cartItem.quantity), 
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _primaryColor)
                      ),
                      Row(
                        children: [
                          _buildQtyButton(
                            icon: Icons.remove, 
                            onTap: () => cart.decreaseQuantity(cartItem.id) 
                          ),
                          SizedBox(
                            width: 32,
                            child: Text(
                              '${cartItem.quantity}', 
                              textAlign: TextAlign.center, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                            ),
                          ),
                          _buildQtyButton(
                            icon: Icons.add, 
                            onTap: () => cart.increaseQuantity(cartItem.id) 
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(width: 80, height: 80, color: Colors.grey.shade100, child: const Icon(Icons.broken_image, color: Colors.grey));
  }

  Widget _buildQtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(color: _primaryColor, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}