import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 

import '../models/product_model.dart';
import '../models/cart_model.dart'; // 🔥 Import model giỏ hàng mới
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // === CÁC BIẾN QUẢN LÝ TRẠNG THÁI ===
  String _selectedSize = 'Size S'; 
  String _selectedIce = 'Đá vừa';
  String _selectedSweetness = '70% đường';
  
  final Map<String, double> _toppings = {
    'Trân châu trắng': 5000.0,
    'Thạch cà phê': 7000.0,
    'Kem cheese': 10000.0,
  };
  final List<String> _selectedToppings = [];

  int _quantity = 1;
  final TextEditingController _noteController = TextEditingController();

  final Color _primaryColor = const Color(0xFFAAC48F); 

  // === LOGIC TÍNH TIỀN ===
  // Tính giá của 1 ly (Gốc + Size + Topping)
  double get _itemPrice {
    double basePrice = widget.product.price.toDouble();

    if (_selectedSize == 'Size M') basePrice += 5000.0;
    if (_selectedSize == 'Size L') basePrice += 10000.0;

    for (String topping in _selectedToppings) {
      basePrice += _toppings[topping]!;
    }

    return basePrice;
  }

  // Tính tổng tiền = Giá 1 ly * Số lượng
  double get _totalPrice => _itemPrice * _quantity;

  String _formatCurrency(double amount) {
    final format = NumberFormat("#,##0", "vi_VN");
    return "${format.format(amount)}đ";
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomBar(),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(),
                _buildDivider(),
                
                _buildSizeSection(),
                _buildDivider(),
                
                _buildIceSection(),
                _buildDivider(),
                
                _buildSweetnessSection(),
                _buildDivider(),
                
                _buildToppingSection(),
                _buildDivider(),
                
                _buildNoteSection(),
                const SizedBox(height: 24),
              ],
            ),
          )
        ],
      ),
    );
  }

  // =======================================================
  // CÁC THÀNH PHẦN GIAO DIỆN (WIDGETS)
  // =======================================================

  Widget _buildSliverAppBar() {
    final isFavorite = context.watch<FavoriteProvider>().isExist(widget.product);

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => context.read<FavoriteProvider>().toggleFavorite(widget.product),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
              color: isFavorite ? const Color(0xFFFA5151) : Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () { /* Chức năng chia sẻ */ },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.share_outlined, color: Colors.black),
          ),
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: widget.product.imageUrl.startsWith('http')
            ? Image.network(widget.product.imageUrl, fit: BoxFit.cover)
            : Image.asset(widget.product.imageUrl, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.product.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1D26)),
                ),
              ),
              Text(
                NumberFormat("#,##0", "vi_VN").format(widget.product.price), 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1D26)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSection() {
    final double basePrice = widget.product.price.toDouble();
    final format = NumberFormat("#,##0", "vi_VN");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Chọn size'),
        _buildCustomRadio(
          title: 'Size S', 
          value: 'Size S', 
          groupValue: _selectedSize, 
          priceStr: format.format(basePrice),
          onChanged: (v) => setState(() => _selectedSize = v!)
        ),
        _buildCustomRadio(
          title: 'Size M', 
          value: 'Size M', 
          groupValue: _selectedSize, 
          priceStr: format.format(basePrice + 5000),
          onChanged: (v) => setState(() => _selectedSize = v!)
        ),
        _buildCustomRadio(
          title: 'Size L', 
          value: 'Size L', 
          groupValue: _selectedSize, 
          priceStr: format.format(basePrice + 10000),
          onChanged: (v) => setState(() => _selectedSize = v!), 
          isLast: true
        ),
      ],
    );
  }

  Widget _buildIceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Chọn đá'),
        _buildCustomRadio(title: 'Ít đá', value: 'Ít đá', groupValue: _selectedIce, onChanged: (v) => setState(() => _selectedIce = v!)),
        _buildCustomRadio(title: 'Đá vừa', value: 'Đá vừa', groupValue: _selectedIce, onChanged: (v) => setState(() => _selectedIce = v!)),
        _buildCustomRadio(title: 'Nhiều đá', value: 'Nhiều đá', groupValue: _selectedIce, onChanged: (v) => setState(() => _selectedIce = v!), isLast: true),
      ],
    );
  }

  Widget _buildSweetnessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Chọn độ ngọt'),
        _buildCustomRadio(title: '50% đường', value: '50% đường', groupValue: _selectedSweetness, onChanged: (v) => setState(() => _selectedSweetness = v!)),
        _buildCustomRadio(title: '70% đường', value: '70% đường', groupValue: _selectedSweetness, onChanged: (v) => setState(() => _selectedSweetness = v!)),
        _buildCustomRadio(title: '100% đường', value: '100% đường', groupValue: _selectedSweetness, onChanged: (v) => setState(() => _selectedSweetness = v!), isLast: true),
      ],
    );
  }

  Widget _buildToppingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Topping thêm (tuỳ chọn)'),
        ..._toppings.entries.map((entry) {
          bool isLast = entry.key == _toppings.keys.last;
          return _buildCustomCheckbox(
            title: entry.key,
            price: entry.value,
            isSelected: _selectedToppings.contains(entry.key),
            onChanged: (bool? checked) {
              setState(() {
                if (checked == true) {
                  _selectedToppings.add(entry.key);
                } else {
                  _selectedToppings.remove(entry.key);
                }
              });
            },
            isLast: isLast,
          );
        }),
      ],
    );
  }

  Widget _buildNoteSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ghi chú cho quán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1D26))),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Ví dụ: "Ít đá, ít ngọt", "Không lấy ống hút"...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _primaryColor)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: _primaryColor, shape: BoxShape.circle),
                  child: const Icon(Icons.remove, color: Colors.white, size: 20),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text('$_quantity', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              GestureDetector(
                onTap: () => setState(() => _quantity++),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: _primaryColor, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                // 🔥 ĐÃ CẬP NHẬT: THÊM DỮ LIỆU THẬT VÀO GIỎ HÀNG 
                onPressed: () {
                  final cartItem = CartItemModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(), 
                    product: widget.product,
                    quantity: _quantity,
                    selectedSize: _selectedSize,
                    selectedIce: _selectedIce,
                    selectedSweetness: _selectedSweetness,
                    selectedToppings: List.from(_selectedToppings),
                    note: _noteController.text,
                    itemPrice: _itemPrice, // Lưu lại giá của 1 ly
                  );

                  context.read<CartProvider>().addItem(cartItem);
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm ${widget.product.name} vào giỏ!'), 
                      backgroundColor: _primaryColor
                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: Text(
                  'Thêm vào giỏ hàng - ${_formatCurrency(_totalPrice)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1D26))),
    );
  }

  Widget _buildDivider() {
    return Container(height: 6, color: const Color(0xFFF8FAFC)); 
  }

  Widget _buildCustomRadio({required String title, required String value, required String groupValue, String? priceStr, required Function(String?) onChanged, bool isLast = false}) {
    bool isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade200))),
        child: Row(
          children: [
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _primaryColor : Colors.white,
                border: Border.all(color: isSelected ? _primaryColor : Colors.grey.shade400, width: 1.5),
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const Spacer(),
            if (priceStr != null) Text(priceStr, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCheckbox({required String title, required double price, required bool isSelected, required Function(bool?) onChanged, bool isLast = false}) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade200))),
        child: Row(
          children: [
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isSelected ? _primaryColor : Colors.white,
                border: Border.all(color: isSelected ? _primaryColor : Colors.grey.shade400, width: 1.5),
              ),
              child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const Spacer(),
            Text('(+${NumberFormat("#,##0", "vi_VN").format(price)} đ)', style: const TextStyle(fontSize: 15, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}