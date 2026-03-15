import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      body: auth.isLoggedIn
          ? _buildProfile(context, auth.currentUser!)
          : _buildGuest(context),
    );
  }

  // ==========================================
  // PROFILE UI (ĐÃ ĐĂNG NHẬP)
  // ==========================================
  Widget _buildProfile(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 1. HEADER (Màu giống Menu, Không bo góc)
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F9F3), // Màu xanh nhạt đồng bộ Menu và Home
            ),
            child: Row(
              children: [
                /// AVATAR
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))
                    ],
                  ),
                  child: const Icon(Icons.person_rounded, size: 40, color: Color(0xFF66BB6A)),
                ),
                const SizedBox(width: 20),

                /// USER INFO (CẬP NHẬT THÊM EMAIL)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên người dùng
                      Text(
                        user.name.isEmpty ? "Người dùng" : user.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1D26)),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // 🔥 THÊM MỚI: Email đã đăng ký
                      if (user.email.isNotEmpty) ...[
                        Text(
                          user.email,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                      ],
                      
                      // Số điện thoại (badge)
                      if (user.phone.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            user.phone,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                          ),
                        ),
                    ],
                  ),
                ),

                /// EDIT BUTTON
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))
                    ]
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_square, color: Color(0xFF66BB6A), size: 20),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// 2. NHÓM TÀI KHOẢN (Account)
          _buildSectionTitle("Tài khoản của tôi"),
          _buildMenuGroup([
            _buildMenuTile(Icons.receipt_long_rounded, "Đơn hàng của tôi", () {}),
            _buildMenuTile(Icons.location_on_outlined, "Địa chỉ giao hàng", () {}),
            _buildMenuTile(Icons.payment_outlined, "Phương thức thanh toán", () {}),
            _buildMenuTile(Icons.local_offer_outlined, "Mã khuyến mãi", () {}, trailingText: "2 mã", showDivider: false),
          ]),

          const SizedBox(height: 24),

          /// 3. NHÓM CÀI ĐẶT & HỖ TRỢ (Settings)
          _buildSectionTitle("Cài đặt & Hỗ trợ"),
          _buildMenuGroup([
            _buildMenuTile(Icons.notifications_none_rounded, "Thông báo", () {}),
            _buildMenuTile(Icons.headset_mic_outlined, "Trung tâm hỗ trợ", () {}),
            _buildMenuTile(Icons.article_outlined, "Điều khoản & Chính sách", () {}, showDivider: false),
          ]),

          const SizedBox(height: 36),

          /// 4. NÚT ĐĂNG XUẤT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.read<AuthProvider>().logout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFA5151), 
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFFA5151), width: 1.5), 
                  ),
                ),
                child: const Text("Đăng xuất", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFA5151))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // GUEST UI (CHƯA ĐĂNG NHẬP)
  // ==========================================
  Widget _buildGuest(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFF66BB6A).withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10))],
              ),
              child: const Icon(Icons.person_off_rounded, size: 72, color: Color(0xFF66BB6A)),
            ),
            const SizedBox(height: 32),
            const Text("Bạn chưa đăng nhập", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1D26))),
            const SizedBox(height: 12),
            Text(
              "Hãy đăng nhập để lưu trữ thông tin,\nquản lý đơn hàng và nhận nhiều ưu đãi!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66BB6A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  shadowColor: const Color(0xFF66BB6A).withOpacity(0.5),
                ),
                child: const Text("ĐĂNG NHẬP / ĐĂNG KÝ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET HỖ TRỢ XÂY DỰNG UI TÀI KHOẢN
  // ==========================================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildMenuGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {String? trailingText, bool showDivider = true}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20), 
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF66BB6A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: const Color(0xFF43A047)),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1A1D26))),
                ),
                
                if (trailingText != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFA5151).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(trailingText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFA5151))),
                  ),
                
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
              ],
            ),
          ),
          
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(left: 62, right: 16), 
              child: Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
            )
        ],
      ),
    );
  }
}