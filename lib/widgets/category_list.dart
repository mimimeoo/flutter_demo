import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import '../models/category_model.dart';

class CategoryList extends StatelessWidget {
  final List<CategoryModel> categories;

  // Danh sách emoji thay thế tạm thời cho app đồ uống
  final List<String> tempEmojis = const ['☕️', '🧋', '🍹', '🥤', '🍵'];

  const CategoryList({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110, // Tăng chiều cao để đủ chỗ cho text rớt xuống 2 dòng
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          // Truyền thêm index để lấy emoji tương ứng
          return _categoryItem(cat, index);
        },
      ),
    );
  }

  Widget _categoryItem(CategoryModel category, int index) {
    // Lấy emoji theo thứ tự
    final String emoji = tempEmojis[index % tempEmojis.length];

    return Container(
      width: 76, // Định hình chiều rộng tối đa cho một cụm (để text tự rớt dòng)
      margin: const EdgeInsets.only(right: 12), // Khoảng cách giữa các danh mục
      child: Column(
        children: [
          /// ICON (Nền xám nhạt, vuông bo góc theo mẫu mới)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {},
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6), // Màu xám rất nhạt (light grey)
                borderRadius: BorderRadius.circular(16), // Bo góc vuông mềm mại
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(
                    fontSize: 32, // Kích thước emoji
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// TEXT (Cho phép 2 dòng)
          Text(
            category.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.3, // Khoảng cách giữa 2 dòng chữ
            ),
            maxLines: 2, // Cho phép rớt xuống 2 dòng (ví dụ: "Trái cây & \n Nước ép")
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}