import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

import '../widgets/product_card.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

// HÀM HỖ TRỢ CHUYỂN TIẾNG VIỆT CÓ DẤU THÀNH KHÔNG DẤU
String removeVietnameseTones(String str) {
  str = str.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
  str = str.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
  str = str.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
  str = str.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
  str = str.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
  str = str.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
  str = str.replaceAll(RegExp(r'[đ]'), 'd');
  str = str.replaceAll(RegExp(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]'), 'A');
  str = str.replaceAll(RegExp(r'[ÈÉẸẺẼÊỀẾỆỂỄ]'), 'E');
  str = str.replaceAll(RegExp(r'[ÌÍỊỈĨ]'), 'I');
  str = str.replaceAll(RegExp(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]'), 'O');
  str = str.replaceAll(RegExp(r'[ÙÚỤỦŨƯỪỨỰỬỮ]'), 'U');
  str = str.replaceAll(RegExp(r'[ỲÝỴỶỸ]'), 'Y');
  str = str.replaceAll(RegExp(r'[Đ]'), 'D');
  return str.toLowerCase();
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedSidebarIndex = 0; 
  int _selectedFilterIndex = 0;  

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _topFilters = [
    {"name": "Tất cả", "icon": Icons.grid_view_rounded},
    {"name": "Bán chạy", "icon": Icons.local_fire_department_outlined},
    {"name": "Must Try", "icon": Icons.favorite_border_rounded},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> loadMenuData() async {
    try {
      final db = FirebaseFirestore.instance;

      final categorySnapshot = await db.collection('categories').get();
      final categories = categorySnapshot.docs.map((doc) => CategoryModel.fromJson(doc.data())).toList();

      final productSnapshot = await db.collection('products').get();
      final products = productSnapshot.docs.map((doc) => ProductModel.fromJson(doc.data())).toList();

      categories.sort((a, b) => a.id.compareTo(b.id));
      categories.insert(0, CategoryModel(id: 'all', name: 'Tất cả', imageUrl: '', description: ''));

      return {'categories': categories, 'products': products};
    } catch (e) {
      throw Exception("Lỗi tải thực đơn: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: loadMenuData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF66BB6A)));

        final categories = snapshot.data!['categories'] as List<CategoryModel>;
        final allProducts = snapshot.data!['products'] as List<ProductModel>;

        List<ProductModel> filteredProducts = [];
        bool isSearching = _searchQuery.isNotEmpty;

        if (isSearching) {
          // LỌC KHÔNG PHÂN BIỆT DẤU TIẾNG VIỆT
          filteredProducts = allProducts.where((p) {
            final nameNormal = removeVietnameseTones(p.name);
            final queryNormal = removeVietnameseTones(_searchQuery);
            return nameNormal.contains(queryNormal);
          }).toList();
        } else {
          final displayCategory = categories[_selectedSidebarIndex];
          filteredProducts = displayCategory.id == 'all' 
              ? allProducts 
              : allProducts.where((p) => p.categoryId == displayCategory.id).toList();

          if (_selectedFilterIndex == 1) {
            filteredProducts = filteredProducts.where((p) => p.isPopular).toList();
          } else if (_selectedFilterIndex == 2) {
            filteredProducts = filteredProducts.where((p) => p.rating >= 4.8).toList();
          }
        }

        return Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFFF3F9F3),
                  child: const SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 20, 24, 40), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Thực đơn", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1D26))),
                          SizedBox(height: 4),
                          Text("Đa dạng lựa chọn cho bạn", style: TextStyle(fontSize: 14, color: Color(0xFF81C784), fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -22,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm đồ uống...",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                        suffixIcon: isSearching 
                            ? IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = ''; 
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 38), 

            if (!isSearching) ...[
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _topFilters.length,
                  itemBuilder: (context, index) {
                    final filter = _topFilters[index];
                    final isSelected = _selectedFilterIndex == index;
                    
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilterIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFAAC48F) : Colors.white, 
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(filter['icon'], size: 16, color: isSelected ? Colors.white : Colors.grey.shade400),
                            const SizedBox(width: 6),
                            Text(
                              filter['name'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade500,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isSearching)
                    Container(
                      width: 62, 
                      decoration: const BoxDecoration(
                        color: Color(0xFF9CB891), 
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 20, bottom: 120), 
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedSidebarIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSidebarIndex = index;
                                _selectedFilterIndex = 0; 
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: double.infinity, 
                              alignment: Alignment.center, 
                              padding: const EdgeInsets.symmetric(vertical: 24), 
                              child: RotatedBox(
                                quarterTurns: 3, 
                                child: Text(
                                  categories[index].name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 15,
                                    letterSpacing: 1.2, 
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  Expanded(
                    child: filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  isSearching ? "Không tìm thấy đồ uống nào!" : "Chưa có sản phẩm", 
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 15, fontWeight: FontWeight.w500)
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 120),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.68, 
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              return ProductCardVertical(
                                product: filteredProducts[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}