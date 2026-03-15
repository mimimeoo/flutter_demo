import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

// 🔥 Thêm Import 2 trang điều hướng
import 'home_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _rememberMe = false;
  final Color _primaryColor = const Color(0xFFAAC48F); // Màu xanh bơ

  // =========================================================
  // LOGIC XỬ LÝ ĐĂNG NHẬP VÀ PHÂN LUỒNG
  // =========================================================
  void _handleLogin() async {
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text.trim();

    if (phone.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ thông tin!')));
      return;
    }

    // Đóng bàn phím khi đang xử lý đăng nhập
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.login(phone, pass);
    
    if (!mounted) return;

    if (result == 'success') {
      // 🔥 KIỂM TRA QUYỀN ĐỂ ĐIỀU HƯỚNG
      if (authProvider.isAdmin) {
        // Tài khoản Admin -> Vào trang Quản trị và xóa lịch sử
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          (route) => false, 
        );
      } else {
        // Tài khoản User -> Vào trang Chủ và xóa lịch sử
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } else {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: Colors.red.shade400));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy trạng thái loading để vô hiệu hóa nút nếu đang xử lý
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
              child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text("Chào mừng trở lại!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            Text("Đăng nhập để tiếp tục thưởng thức\nđồ uống yêu thích của bạn", style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5)),
            const SizedBox(height: 40),

            _buildInputField("Email hoặc Số điện thoại", "Nhập email hoặc số điện thoại", _phoneController),
            const SizedBox(height: 20),
            _buildInputField("Mật khẩu", "Nhập mật khẩu", _passwordController, isPassword: true),
            
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 24, height: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: _primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: BorderSide(color: Colors.grey.shade400),
                    onChanged: (v) => setState(() => _rememberMe = v!),
                  ),
                ),
                const SizedBox(width: 8),
                Text("Ghi nhớ đăng nhập", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                  child: Text("Quên mật khẩu?", style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                )
              ],
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)), 
                  elevation: 0
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24, height: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text("Đăng Nhập", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Hoặc đăng nhập bằng", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildSocialButton("Google", Icons.g_mobiledata_rounded, Colors.red)),
                const SizedBox(width: 16),
                Expanded(child: _buildSocialButton("Facebook", Icons.facebook_rounded, Colors.blue)),
              ],
            ),

            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Bạn chưa có tài khoản? ", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: Text("Đăng Ký", style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && _isObscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryColor, width: 1.5)),
            suffixIcon: isPassword 
                ? IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade400, size: 20),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ) 
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String name, IconData icon, Color iconColor) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: iconColor, size: 24),
      label: Text(name, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
    );
  }
}