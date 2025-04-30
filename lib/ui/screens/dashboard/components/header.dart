import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techgear/controllers/map_dashboard_controller.dart';
import 'package:techgear/ui/screens/dashboard/responsive.dart';
import 'package:techgear/ui/widgets/common/custom_text_field.dart';

class Header extends StatefulWidget {
  final String title;

  const Header({
    super.key,
    required this.title,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> with SingleTickerProviderStateMixin {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Thời gian hiệu ứng
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Bắt đầu từ bên phải
      end: Offset.zero, // Kết thúc ở vị trí bình thường
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (_isSearchActive) {
        _animationController
            .forward(); // Chạy animation khi TextField xuất hiện
      } else {
        _animationController.reverse(); // Chạy ngược khi TextField ẩn
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 8.0), // Giữ kích thước gốc
      color: const Color(0xFF0068FF), // Màu xanh Zalo
      child: Row(
        children: [
          // Icon menu trên mobile
          if (!Responsive.isDesktop(context))
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                context.read<MenuAppController>().openDrawer(context);
              },
            ),
          if (!Responsive.isDesktop(context))
            const SizedBox(width: 10), // Giữ kích thước gốc
          // Title hoặc TextField
          Expanded(
            child: _isSearchActive && Responsive.isMobile(context)
                ? SlideTransition(
                    position: _slideAnimation,
                    child: CustomTextField(
                      controller: _searchController,
                      hint: "Search users",
                      isSearch: true,
                      inputType: TextInputType.text,
                    ),
                  )
                : Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22, // Giữ kích thước gốc
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          // TextField trên desktop/tablet khi không tìm kiếm
          if (!_isSearchActive && !Responsive.isMobile(context))
            SizedBox(
              width: 300, // Giữ kích thước gốc
              child: CustomTextField(
                controller: _searchController,
                hint: "Search users",
                isSearch: true,
                inputType: TextInputType.text,
              ),
            ),
          // Nút tìm kiếm/hủy trên mobile
          if (Responsive.isMobile(context))
            IconButton(
              icon: Icon(
                _isSearchActive ? Icons.close : Icons.search,
                color: Colors.white,
              ),
              onPressed: _toggleSearch,
            ),
          // ProfileCard
          if (!Responsive.isMobile(context)) SizedBox(width: 16),
          const ProfileCard(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 8.0), // Giữ kích thước gốc
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Nền trắng mờ giống Zalo
        borderRadius:
            const BorderRadius.all(Radius.circular(10)), // Giữ kích thước gốc
        border: Border.all(color: Colors.white10), // Giữ border gốc
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            child: Image.asset(
              "assets/images/tech_gear_logo.png",
              height: 38,
              // Giữ kích thước gốc
            ),
          ),
          if (!Responsive.isMobile(context))
            const Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.0), // Giữ kích thước gốc
              child: Text(
                "Admin",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
      ),
    );
  }
}
