import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/login_screen.dart'; 

class HomeHeader extends StatelessWidget {
  // THÊM: Các biến để quản lý tìm kiếm
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback onClear;

  const HomeHeader({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoggedIn = auth.isLoggedIn;
    final userName = auth.currentUser?.name ?? "Khách";

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoggedIn)
                      Text.rich(
                        TextSpan(
                          text: "Xin chào,\n", 
                          style: const TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF1A1D26),
                            height: 1.2,
                          ),
                          children: [
                            TextSpan(
                              text: "$userName!", 
                              style: const TextStyle(
                                color: Color(0xFF66BB6A), 
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Text(
                        "Xin chào!", 
                        style: TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFF1A1D26),
                          height: 1.2,
                        )
                      ),
                    const SizedBox(height: 6),
                    const Text(
                      "Bạn muốn uống gì hôm nay?", 
                      style: TextStyle(fontSize: 14, color: Color(0xFF81C784), fontWeight: FontWeight.w500)
                    ),
                  ],
                ),
              ),

              if (isLoggedIn)
                Row(
                  children: [
                    _buildTopIcon(Icons.local_offer_outlined, onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trang khuyến mãi')));
                    }),
                    const SizedBox(width: 12),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildTopIcon(Icons.notifications_none_rounded, onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trang thông báo')));
                        }),
                        Positioned(
                          top: -2, right: -2,
                          child: Container(
                            width: 12, height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFA5151), 
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66BB6A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10)
                  ),
                  child: const Text("Đăng nhập", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                )
            ],
          ),
          
          const SizedBox(height: 24),
          
          // THANH TÌM KIẾM CÓ CHỨC NĂNG
          Container(
            height: 52, 
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26), 
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearch,
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm đồ uống...",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      border: InputBorder.none,
                      // Hiện nút X nếu đã có chữ
                      suffixIcon: searchController.text.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                              onPressed: onClear,
                            )
                          : null,
                    ),
                  ),
                ),
                Container(
                  width: 1, height: 24, 
                  color: Colors.grey.shade200,
                ),
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Color(0xFF66BB6A), size: 22),
                  onPressed: () {},
                  splashRadius: 20,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopIcon(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1A1D26), size: 22),
      ),
    );
  }
}