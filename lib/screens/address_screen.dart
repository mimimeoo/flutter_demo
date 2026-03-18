import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final Color _primaryGreen = const Color(0xFFAAC48F); 

  // Hàm suy luận Icon dựa vào tên
  IconData _getIcon(String title) {
    return title.toLowerCase().contains("công ty") ? Icons.domain : Icons.home_rounded;
  }

  // =======================================================
  // LOGIC LƯU LÊN FIREBASE
  // =======================================================
  void _deleteAddress(String userId, String id, bool isDefault) async {
    final collection = FirebaseFirestore.instance.collection('users').doc(userId).collection('addresses');
    await collection.doc(id).delete();
    
    // Nếu xóa mất địa chỉ mặc định, tự động lấy 1 địa chỉ khác làm mặc định
    if (isDefault) {
      final remaining = await collection.limit(1).get();
      if (remaining.docs.isNotEmpty) {
        await remaining.docs.first.reference.update({'isDefault': true});
      }
    }
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa địa chỉ")));
  }

  void _saveAddress(String userId, List<Map<String, dynamic>> currentList, {String? id, required Map<String, dynamic> newData}) async {
    final collection = FirebaseFirestore.instance.collection('users').doc(userId).collection('addresses');

    // Ép làm mặc định nếu là địa chỉ đầu tiên
    if (currentList.isEmpty) {
      newData['isDefault'] = true;
    } 

    // Nếu chọn làm mặc định, phải tắt mặc định của các địa chỉ cũ
    if (newData['isDefault'] == true) {
      final batch = FirebaseFirestore.instance.batch();
      final defaultDocs = await collection.where('isDefault', isEqualTo: true).get();
      for (var doc in defaultDocs.docs) {
        if (doc.id != id) {
          batch.update(doc.reference, {'isDefault': false});
        }
      }
      await batch.commit();
    }

    if (id == null) {
      // THÊM MỚI
      final newDoc = collection.doc();
      newData['id'] = newDoc.id; // Lưu id vào trong data luôn cho tiện
      await newDoc.set(newData);
    } else {
      // CẬP NHẬT
      await collection.doc(id).update(newData);
    }
  }

  // =======================================================
  // BOTTOM SHEET: FORM THÊM / SỬA ĐỊA CHỈ
  // =======================================================
  void _showAddressForm(String userId, List<Map<String, dynamic>> currentList, {String? id}) {
    final isEditing = id != null;
    final addressData = isEditing ? currentList.firstWhere((a) => a['id'] == id) : null;

    final titleController = TextEditingController(text: addressData?['title'] ?? '');
    final nameController = TextEditingController(text: addressData?['name'] ?? '');
    final phoneController = TextEditingController(text: addressData?['phone'] ?? '');
    final addressController = TextEditingController(text: addressData?['address'] ?? '');
    bool isDefault = addressData?['isDefault'] ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24, left: 24, right: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 24),
                  
                  Text(isEditing ? "Chỉnh sửa địa chỉ" : "Thêm địa chỉ mới", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel("Tên gợi nhớ (VD: Nhà riêng, Công ty)"),
                          _buildTextField(titleController, "Nhập tên gợi nhớ"),
                          
                          _buildInputLabel("Tên người nhận"),
                          _buildTextField(nameController, "Nhập họ và tên"),
                          
                          _buildInputLabel("Số điện thoại"),
                          _buildTextField(phoneController, "Nhập số điện thoại", keyboardType: TextInputType.phone),
                          
                          _buildInputLabel("Địa chỉ chi tiết"),
                          _buildTextField(addressController, "Nhập địa chỉ nhận hàng..."),
                          
                          const SizedBox(height: 16),

                          if (!isDefault || currentList.length <= 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Đặt làm địa chỉ mặc định", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                Switch(
                                  value: isDefault,
                                  activeColor: _primaryGreen,
                                  onChanged: (val) => setModalState(() => isDefault = val),
                                )
                              ],
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameController.text.isEmpty || phoneController.text.isEmpty || addressController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng điền đủ thông tin")));
                              return;
                            }

                            final newData = {
                              "title": titleController.text.isNotEmpty ? titleController.text : "Khác",
                              "name": nameController.text,
                              "phone": phoneController.text,
                              "address": addressController.text,
                              "isDefault": isDefault,
                            };

                            _saveAddress(userId, currentList, id: isEditing ? addressData!['id'] : null, newData: newData);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text("Lưu địa chỉ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

  // =======================================================
  // GIAO DIỆN CHÍNH
  // =======================================================
  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().currentUser?.id;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Địa chỉ giao hàng"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
        body: const Center(child: Text("Vui lòng đăng nhập để quản lý địa chỉ")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
              child: Icon(Icons.arrow_back, color: Colors.grey.shade600, size: 20),
            ),
          ),
        ),
        title: const Text("Địa chỉ giao hàng", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).collection('addresses').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Chuyển dữ liệu Firebase thành List Map
          final addresses = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Gắn ID của tài liệu vào data
            return data;
          }).toList();

          final defaultAddresses = addresses.where((a) => a['isDefault'] == true).toList();
          final otherAddresses = addresses.where((a) => a['isDefault'] != true).toList();

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (defaultAddresses.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("Địa chỉ mặc định", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                      ),
                      ...defaultAddresses.map((addr) => _buildAddressCard(userId, addresses, addr)),
                    ],

                    if (otherAddresses.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("Địa chỉ khác", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                      ),
                      ...otherAddresses.map((addr) => _buildAddressCard(userId, addresses, addr)),
                    ],

                    if (addresses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 20),
                        child: Center(child: Text("Bạn chưa có địa chỉ giao hàng nào.", style: TextStyle(color: Colors.grey.shade500))),
                      ),

                    const SizedBox(height: 16),
                    _buildMapSection(),
                    const SizedBox(height: 100), 
                  ],
                ),
              ),

              // Nút Thêm cố định ở đáy
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFFF5F5F5),
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddressForm(userId, addresses),
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    label: const Text("Thêm địa chỉ mới", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  // WIDGET: Thẻ Địa chỉ
  Widget _buildAddressCard(String userId, List<Map<String, dynamic>> currentList, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        // TRẢ VỀ CHO TRANG CHECKOUT
        Navigator.pop(context, data);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getIcon(data['title']), color: data['isDefault'] == true ? const Color(0xFFD84315) : const Color(0xFF1565C0), size: 20),
                      const SizedBox(width: 8),
                      Text(data['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(data['name'], style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(data['phone'], style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(data['address'], style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _showAddressForm(userId, currentList, id: data['id']),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: Text("Chỉnh sửa", style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold, fontSize: 14))),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _deleteAddress(userId, data['id'], data['isDefault'] ?? false),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: Text("Xóa", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14))),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size.infinite, painter: MapGridPainter()),
          const Positioned(top: 25, child: Icon(Icons.location_on, color: Colors.red, size: 40)),
          Positioned(
            bottom: 16, left: 16, right: 16,
            child: ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chức năng bản đồ cần tích hợp Google Maps SDK"))),
              style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 2),
              child: const Text("Chọn vị trí trên bản đồ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _primaryGreen, width: 1.5)),
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.6)..strokeWidth = 4.0;
    canvas.drawLine(const Offset(0, 40), Offset(size.width, 80), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.7, size.height), paint);
    canvas.drawLine(Offset(0, size.height - 20), Offset(size.width, 10), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}