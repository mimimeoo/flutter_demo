import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Bộ điều khiển các ô nhập liệu
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isObscurePass = true;
  bool _isObscureConfirm = true;
  bool _agreePolicy = false;
  
  final Color _primaryColor = const Color(0xFFAAC48F);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // HÀM KIỂM TRA ĐIỀU KIỆN & GỌI API ĐĂNG KÝ
  void _handleRegister() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    final confirmPass = _confirmPasswordController.text;

    // 1. Kiểm tra không được để trống
    if (name.isEmpty || phone.isEmpty || email.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
      _showError('Vui lòng nhập đầy đủ thông tin!');
      return;
    }

    // 2. Kiểm tra số điện thoại (Từ 10 số)
    if (phone.length < 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showError('Số điện thoại không hợp lệ (phải từ 10 số)!');
      return;
    }

    // 3. Kiểm tra định dạng Email hợp lệ
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(email)) {
      _showError('Định dạng email không hợp lệ!');
      return;
    }

    // 4. Kiểm tra độ dài mật khẩu (Từ 6 ký tự)
    if (pass.length < 6) {
      _showError('Mật khẩu phải từ 6 ký tự trở lên!');
      return;
    }

    // 5. Kiểm tra mật khẩu khớp nhau
    if (pass != confirmPass) {
      _showError('Mật khẩu xác nhận không khớp!');
      return;
    }

    // 6. Kiểm tra đồng ý điều khoản
    if (!_agreePolicy) {
      _showError('Vui lòng đồng ý với Điều khoản & Chính sách!');
      return;
    }

    // Đóng bàn phím
    FocusScope.of(context).unfocus();

    // 7. GỌI API ĐĂNG KÝ TỪ AUTH PROVIDER
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.register(name, email, phone, pass);
    
    if (!mounted) return;

    if (result == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công!"), backgroundColor: Colors.green)
      );
      // Đăng ký xong tự động vào HomeScreen và xóa lịch sử trang
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      _showError(result); // Hiện thông báo lỗi trùng lặp từ Server
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
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
            const Text("Tạo tài khoản mới", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            Text("Tham gia BrewGo để nhận ưu đãi và\nđặt đồ uống nhanh chóng", style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5)),
            const SizedBox(height: 32),

            _buildInputField("Họ và tên", "Nhập họ và tên của bạn", _nameController),
            const SizedBox(height: 16),
            _buildInputField("Số điện thoại", "Nhập số điện thoại", _phoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildInputField("Email", "Nhập email của bạn", _emailController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildPasswordField("Mật khẩu", "Tạo mật khẩu", _passwordController, _isObscurePass, () => setState(() => _isObscurePass = !_isObscurePass)),
            const SizedBox(height: 16),
            _buildPasswordField("Xác nhận mật khẩu", "Nhập lại mật khẩu", _confirmPasswordController, _isObscureConfirm, () => setState(() => _isObscureConfirm = !_isObscureConfirm)),
            
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24, height: 24,
                  child: Checkbox(
                    value: _agreePolicy,
                    activeColor: _primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: BorderSide(color: Colors.grey.shade400),
                    onChanged: (v) => setState(() => _agreePolicy = v!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text("Tôi đồng ý với Điều khoản & Chính sách của BrewGo", style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.4)),
                ),
              ],
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleRegister,
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
                    : const Text("Đăng Ký", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                Text("Bạn đã có tài khoản? ", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                GestureDetector(
                  onTap: () => Navigator.pop(context), 
                  child: Text("Đăng nhập", style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryColor, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, String hint, TextEditingController controller, bool isObscure, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryColor, width: 1.5)),
            suffixIcon: IconButton(
              icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade400, size: 20),
              onPressed: onToggle,
            ),
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