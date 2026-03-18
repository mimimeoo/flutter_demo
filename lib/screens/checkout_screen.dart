import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_model.dart';
import 'order_success_screen.dart';
import 'address_screen.dart'; 

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Color _primaryColor = const Color(0xFFAAC48F); 
  int _selectedPaymentMethod = 0; 
  Map<String, dynamic>? _selectedAddress;

  @override
  void initState() {
    super.initState();
    // Tự động tải địa chỉ mặc định từ Firebase khi mở trang Checkout
    Future.microtask(() => _loadDefaultAddress());
  }

  Future<void> _loadDefaultAddress() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.id)
        .collection('addresses')
        .where('isDefault', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty && mounted) {
      setState(() {
        _selectedAddress = snapshot.docs.first.data();
        _selectedAddress!['id'] = snapshot.docs.first.id;
      });
    }
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat("#,##0", "vi_VN");
    return "${format.format(amount)}đ";
  }

  IconData _getIcon(String? title) {
    if (title == null) return Icons.location_on;
    return title.toLowerCase().contains("công ty") ? Icons.domain : Icons.home_rounded;
  }

  Future<void> _selectAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedAddress = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items.values.toList();

    double subtotal = cart.totalAmount;
    double deliveryFee = 15000.0; 
    double discount = 10000.0; 
    double total = subtotal + deliveryFee - discount;

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
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
                child: Icon(Icons.arrow_back, color: Colors.grey.shade600, size: 20),
              ),
            ),
            Text("Thanh toán", style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(width: 36), 
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GIAO HÀNG TẬN NƠI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Giao hàng tận nơi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: _selectAddress,
                  child: Text(
                    _selectedAddress == null ? "Chọn địa chỉ" : "Thay đổi", 
                    style: TextStyle(fontSize: 14, color: _primaryColor, fontWeight: FontWeight.w600)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _selectAddress,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _selectedAddress == null ? Colors.red.shade200 : Colors.transparent),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _selectedAddress != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(_getIcon(_selectedAddress!['title']), size: 16, color: _primaryColor),
                                    const SizedBox(width: 6),
                                    Text(_selectedAddress!['title'] ?? 'Địa chỉ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _primaryColor)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text("${_selectedAddress!['name']} • ${_selectedAddress!['phone']}", style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text(_selectedAddress!['address'], style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade400, size: 20),
                                  const SizedBox(width: 8),
                                  Text("Vui lòng chọn địa chỉ giao hàng", style: TextStyle(fontSize: 14, color: Colors.red.shade400, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _primaryColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. SẢN PHẨM ĐÃ CHỌN
            const Text("Sản phẩm đã chọn", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...items.map((cartItem) => _buildCheckoutItemCard(cartItem)).toList(),
            const SizedBox(height: 24),

            // 3. PHƯƠNG THỨC THANH TOÁN
            const Text("Phương thức thanh toán", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPaymentOption(0, Icons.money_outlined, "Thanh toán khi nhận hàng"),
            _buildPaymentOption(1, Icons.account_balance_wallet_outlined, "Ví điện tử"),
            _buildPaymentOption(2, Icons.credit_card_outlined, "Thẻ ATM và Tài khoản ngân hàng"),
            _buildPaymentOption(3, Icons.payment_outlined, "Thẻ thanh toán quốc tế"),
            const SizedBox(height: 24),

            // 4. TỔNG KẾT
            const Text("Thanh toán", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSummaryRow("Tạm tính:", _formatCurrency(subtotal), Colors.black87),
            _buildSummaryRow("Phí giao hàng:", _formatCurrency(deliveryFee), Colors.black87),
            _buildSummaryRow("Giảm giá:", _formatCurrency(discount), Colors.black87),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
            _buildSummaryRow("Tổng thanh toán:", _formatCurrency(total), _primaryColor, isBold: true),
            const SizedBox(height: 40), 
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade100, width: 2))),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedAddress == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng trước khi đặt!'), backgroundColor: Colors.red));
                  return;
                }
                context.read<CartProvider>().clearCart();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const OrderSuccessScreen()), (Route<dynamic> route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)), elevation: 0),
              child: const Text("Đặt hàng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutItemCard(CartItemModel cartItem) {
    String sizeLetter = cartItem.selectedSize.replaceAll('Size ', '');
    String optionsText = "Size: $sizeLetter";
    if (cartItem.selectedIce.isNotEmpty) optionsText += "\n• ${cartItem.selectedIce}";
    if (cartItem.selectedSweetness.isNotEmpty) optionsText += "\n• ${cartItem.selectedSweetness}";
    if (cartItem.selectedToppings.isNotEmpty) optionsText += "\n• Thêm: ${cartItem.selectedToppings.join(', ')}";

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: cartItem.product.imageUrl.startsWith('http')
                ? Image.network(cartItem.product.imageUrl, width: 70, height: 70, fit: BoxFit.cover)
                : Image.asset(cartItem.product.imageUrl, width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cartItem.product.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1D26)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(optionsText, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatCurrency(cartItem.itemPrice), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _primaryColor)),
                    Text("x${cartItem.quantity}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(int index, IconData icon, String title) {
    bool isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: isSelected ? _primaryColor.withOpacity(0.08) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? _primaryColor : Colors.grey.shade300, width: 1.5)),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? _primaryColor : Colors.black87, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontSize: 14, color: isSelected ? _primaryColor : Colors.black87, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal))),
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? _primaryColor : Colors.white, border: Border.all(color: isSelected ? _primaryColor : Colors.grey.shade400, width: 1.5)),
              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? valueColor : Colors.black87, fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(color: valueColor, fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}