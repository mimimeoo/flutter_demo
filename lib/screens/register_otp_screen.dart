import 'package:flutter/material.dart';

class RegisterOtpScreen extends StatefulWidget {
  final String email;
  const RegisterOtpScreen({super.key, required this.email});

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final Color _primaryColor = const Color(0xFFAAC48F);

  @override
  void dispose() {
    for (var node in _focusNodes) { node.dispose(); }
    for (var controller in _controllers) { controller.dispose(); }
    super.dispose();
  }

  void _verifyRegistrationOtp() {
    // Thu thập 6 số OTP
    String otp = _controllers.map((c) => c.text).join();
    
    if(otp.length == 6) {
      // Xác thực thành công -> Báo thành công và quay lại Đăng nhập
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đăng ký tài khoản thành công! Vui lòng đăng nhập.'),
          backgroundColor: _primaryColor,
          behavior: SnackBarBehavior.floating,
        )
      );
      // Xóa các màn hình đăng ký và về thẳng trang gốc (Login)
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập đủ 6 số OTP'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text("Xác minh Email", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                text: "Nhập mã 6 số đã được gửi đến email\n",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                children: [
                  TextSpan(
                    text: widget.email,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  )
                ]
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Khu vực 6 ô nhập OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return Container(
                  width: 48, height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _focusNodes[index].hasFocus ? _primaryColor : Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(counterText: "", border: InputBorder.none),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Chưa nhận được mã? ", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                const Text("Nhấn để gửi lại", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Text("Gửi lại sau: 0:30", style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _verifyRegistrationOtp,
                style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)), elevation: 0),
                child: const Text("Xác nhận Đăng ký", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}