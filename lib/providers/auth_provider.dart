import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _currentUser = UserModel(
          name: user.displayName ?? "Khách hàng", 
          phone: user.email ?? "", 
          password: '***' 
        );
      } else {
        _currentUser = null;
      }
      notifyListeners(); 
    });
  }

  Future<String> register(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );

      await userCredential.user!.updateDisplayName(name);
      
      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') return 'Mật khẩu quá yếu (cần ít nhất 6 ký tự)!';
      if (e.code == 'email-already-in-use') return 'Email này đã được đăng ký!';
      if (e.code == 'invalid-email') return 'Định dạng Email không hợp lệ!';
      return 'Lỗi: ${e.message}';
    } catch (e) {
      return 'Đã xảy ra lỗi không xác định!';
    }
  }

  Future<String> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
        return 'Sai email hoặc mật khẩu!';
      }
      if (e.code == 'invalid-email') return 'Định dạng Email không hợp lệ!';
      return 'Lỗi đăng nhập: ${e.message}';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}