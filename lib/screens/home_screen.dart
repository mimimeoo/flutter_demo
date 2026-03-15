import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

import '../widgets/carousel_slider.dart';
import '../widgets/product_card.dart';
import '../widgets/category_list.dart'; 
import '../widgets/home_header.dart'; 
import '../widgets/custom_bottom_nav.dart'; 
import '../models/category_model.dart'; 
import '../models/product_model.dart';

import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart'; 
import 'login_screen.dart';               
import 'menu_screen.dart';
import 'favorite_screen.dart';
import 'profile_screen.dart'; 
import 'cart_screen.dart';    

// IMPORT TRANG ĐỊA CHỈ & CHỌN CỬA HÀNG
import 'address_screen.dart';
import 'store_selection_screen.dart';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> loadAppData() async {
    try {
      final db = FirebaseFirestore.instance;

      final categorySnapshot = await db.collection('categories').get();
      final categories = categorySnapshot.docs.map((doc) => CategoryModel.fromJson(doc.data())).toList();

      final productSnapshot = await db.collection('products').get();
      final products = productSnapshot.docs.map((doc) => ProductModel.fromJson(doc.data())).toList();

      categories.sort((a, b) => a.id.compareTo(b.id));

      return {'categories': categories, 'products': products};
    } catch (e) {
      throw Exception("Không thể kết nối máy chủ Firebase: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    int cartItemCount = context.watch<CartProvider>().itemCount;

    Widget currentScreen;
    switch (_selectedIndex) {
      case 0:
        currentScreen = _buildHomeContent(); 
        break;
      case 1:
        currentScreen = const MenuScreen();
        break;
      case 2:
        currentScreen = const FavoriteScreen();
        break;
      case 3:
        currentScreen = const ProfileScreen(); 
        break;
      default:
        currentScreen = _buildHomeContent();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, 
      floatingActionButton: cartItemCount > 0 ? _buildFloatingCart(cartItemCount) : null,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: currentScreen,
      ),
    );
  }

  Widget _buildHomeContent() {
    return FutureBuilder<Map<String, dynamic>>(
      key: const ValueKey('HomeTab'), 
      future: loadAppData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Lỗi hệ thống: Đang bảo trì", style: TextStyle(color: Colors.grey)));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF66BB6A)));

        final categories = snapshot.data!['categories'] as List<CategoryModel>;
        final allProducts = snapshot.data!['products'] as List<ProductModel>;

        bool isSearching = _searchQuery.isNotEmpty;
        List<ProductModel> searchResults = [];

        if (isSearching) {
          searchResults = allProducts.where((p) {
            final nameNormal = removeVietnameseTones(p.name);
            final queryNormal = removeVietnameseTones(_searchQuery);
            return nameNormal.contains(queryNormal);
          }).toList();
        }

        final homeProducts = allProducts.where((p) => p.showOnHome).toList();
        final bestSellers = homeProducts.where((p) => p.isPopular).toList();
        final recommended = homeProducts.where((p) => !p.isPopular).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: const Color(0xFFF3F9F3), 
                child: SafeArea(
                  bottom: false, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeHeader(
                        searchController: _searchController,
                        onSearch: (value) {
                          setState(() => _searchQuery = value);
                        },
                        onClear: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          FocusScope.of(context).unfocus(); 
                        },
                      ),
                      if (!isSearching) ...[
                        CustomCarouselSlider(),
                        const SizedBox(height: 12),
                        _buildDeliveryInfo(context), 
                        const SizedBox(height: 16), 
                      ]
                    ],
                  ),
                ),
              ),

              if (isSearching) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Text("Kết quả tìm kiếm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1D26))),
                ),
                searchResults.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text("Không tìm thấy đồ uống nào!", style: TextStyle(color: Colors.grey.shade500, fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, 
                          crossAxisSpacing: 16, 
                          mainAxisSpacing: 16, 
                          childAspectRatio: 0.68, 
                        ),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          return ProductCardVertical(product: searchResults[index]);
                        },
                      ),
                    ),
              ] 
              else ...[
                const SizedBox(height: 20),
                _buildSectionTitle("Danh mục", showSeeMore: false),
                const SizedBox(height: 12), 
                CategoryList(categories: categories),

                const SizedBox(height: 24),
                _buildSectionTitle("Best Seller"),
                const SizedBox(height: 12), 
                bestSellers.isEmpty 
                    ? const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Đang cập nhật...", style: TextStyle(color: Colors.grey)))
                    : SizedBox(
                        height: 260, 
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: bestSellers.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: ProductCardVertical(product: bestSellers[index], width: 160),
                            );
                          },
                        ),
                      ),

                const SizedBox(height: 24),
                _buildSectionTitle("Dành cho bạn"),
                const SizedBox(height: 12),
                recommended.isEmpty
                    ? const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Đang cập nhật...", style: TextStyle(color: Colors.grey)))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.68, 
                          ),
                          itemCount: recommended.length,
                          itemBuilder: (context, index) => ProductCardVertical(product: recommended[index]),
                        ),
                      ),

                const SizedBox(height: 16),
                _buildSectionTitle("Cửa hàng gần bạn"),
                const SizedBox(height: 12),
                _buildNearbyStores(),
              ],

              const SizedBox(height: 120), 
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // 🔥 CẬP NHẬT MỚI: DANH SÁCH CỬA HÀNG HIỂN THỊ DẠNG THẺ NGANG VỚI HÌNH ẢNH
  // =========================================================================
  Widget _buildNearbyStores() {
    // Tái sử dụng dữ liệu đầy đủ từ trang store_selection_screen
    final List<Map<String, dynamic>> stores = [
      {
        "name": "BrewGo Quận 1",
        "address": "123 Lê Lợi, Phường Bến Thành, Quận 1, TP. HCM",
        "distance": "0.5 km",
        "isOpen": true,
        "imageUrl": "https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=500"
      },
      {
        "name": "BrewGo Thảo Điền",
        "address": "45 Xuân Thủy, Thảo Điền, Quận 2, TP. HCM",
        "distance": "3.2 km",
        "isOpen": true,
        "imageUrl": "https://images.unsplash.com/photo-1559925393-8be0ec4767c8?w=500"
      },
      {
        "name": "BrewGo Phú Mỹ Hưng",
        "address": "SH-03 Tôn Dật Tiên, Quận 7, TP. HCM",
        "distance": "5.8 km",
        "isOpen": false,
        "imageUrl": "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=500"
      },
    ];

    return SizedBox(
      height: 240, // Đủ chiều cao để chứa ảnh và thông tin
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stores.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final store = stores[index];
          bool isOpen = store['isOpen'];
          
          return Container(
            width: 280, // Chiều rộng của mỗi thẻ lướt ngang
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hình ảnh cửa hàng
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        store['imageUrl'],
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          height: 130, 
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.storefront, color: Colors.grey, size: 40),
                        ),
                      ),
                    ),
                    // Lớp mờ nếu đóng cửa
                    if (!isOpen)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "ĐÃ ĐÓNG CỬA", 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                          ),
                        ),
                      ),
                  ],
                ),
                // 2. Thông tin chi tiết
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store['name'], 
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isOpen ? const Color(0xFF1A1D26) : Colors.grey.shade600), 
                        maxLines: 1, overflow: TextOverflow.ellipsis
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store['address'], 
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500), 
                        maxLines: 1, overflow: TextOverflow.ellipsis
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Color(0xFF66BB6A)),
                          const SizedBox(width: 4),
                          Text(store['distance'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Icon(Icons.access_time, size: 14, color: isOpen ? const Color(0xFF66BB6A) : Colors.red),
                          const SizedBox(width: 4),
                          Text(
                            isOpen ? "Đang mở cửa" : "Đã đóng",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isOpen ? const Color(0xFF66BB6A) : Colors.red),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================================

  Widget _buildFloatingCart(int cartItemCount) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF66BB6A), 
      elevation: 6, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
      },
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, 
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 26, color: Colors.white),
          Positioned(
            right: -4, top: -6,
            child: TweenAnimationBuilder<double>(
              key: ValueKey(cartItemCount), 
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) => Transform.scale(scale: value, child: child),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFA5151), shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF66BB6A), width: 2), 
                ),
                child: Text('$cartItemCount', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold, height: 1)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
          if (!isLoggedIn) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          } else {
            _showDeliveryBottomSheet(context);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), 
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))]),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFF3F9F3), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delivery_dining, color: Color(0xFF81C784), size: 22)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Text("Giao hàng tận nơi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), SizedBox(width: 4), Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF43A047))]),
                    SizedBox(height: 2),
                    Text("Sản phẩm được giao đến địa chỉ của bạn", style: TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeliveryBottomSheet(BuildContext context) {
    int selectedMethod = 0; 
    final Color primaryColor = const Color(0xFF66BB6A); // Màu chủ đạo mới

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("Phương thức nhận hàng", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 20),

                  _buildMethodOption(
                    title: "Giao hàng tận nơi",
                    subtitle: "Sản phẩm được giao đến địa chỉ của bạn",
                    icon: Icons.delivery_dining_outlined,
                    isSelected: selectedMethod == 0,
                    primaryColor: primaryColor,
                    onTap: () {
                      setModalState(() => selectedMethod = 0);
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen()));
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildMethodOption(
                    title: "Đến lấy tại",
                    subtitle: "Bạn sẽ đến nhận hàng tại quầy của cửa hàng",
                    icon: Icons.takeout_dining_outlined, 
                    isSelected: selectedMethod == 1,
                    primaryColor: primaryColor,
                    onTap: () {
                      setModalState(() => selectedMethod = 1);
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreSelectionScreen()));
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMethodOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? primaryColor : Colors.black87, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isSelected ? primaryColor : Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.3)),
                ],
              ),
            ),
            Icon(Icons.arrow_right, size: 24, color: isSelected ? primaryColor : Colors.black87),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showSeeMore = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1D26))),
          if (showSeeMore)
            Row(children: [Text("Xem thêm", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)), const SizedBox(width: 2), Icon(Icons.arrow_forward, size: 14, color: Colors.grey.shade400)])
        ],
      ),
    );
  }
}