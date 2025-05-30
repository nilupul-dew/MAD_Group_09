import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hiking_app/data/firebase_services/user/auth_service.dart';
import 'package:hiking_app/presentation/screens/item/cart_page.dart';
import 'package:hiking_app/presentation/screens/notification_screen.dart';
import 'package:hiking_app/presentation/screens/user/user_profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final int cartItemCount;
  final VoidCallback? onCartPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final ValueChanged<String>? onSearchChanged;
  final Widget? title;

  const CustomAppBar({
    Key? key,
    this.cartItemCount = 0,
    this.onCartPressed,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.onSearchChanged,
    this.title,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileImage();
  }

  Future<void> _fetchUserProfileImage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final data = await AuthService.getUserDataById(currentUser.uid);
      if (data != null && mounted) {
        setState(() {
          _profileImageUrl = data['profileImage'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/home');
            },
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/home');
                  },
                  child: Image.asset('assets/images/AmbaLogo.png', height: 50),
                ),
                const SizedBox(width: 8),
                Text(
                  "AMBA CAMPING",
                  style: GoogleFonts.montserrat(
                    color: Color.fromARGB(181, 18, 18, 18),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        offset: Offset(3.0, 2.0),
                        blurRadius: 4.0,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      actions: [
        _buildIconButton(
          icon: Icons.shopping_cart_outlined,
          onPressed: widget.onCartPressed ??
              () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => CartScreen()));
              },
          badgeText: '${widget.cartItemCount}',
        ),
        _buildIconButton(
          icon: Icons.notifications_none,
          iconColor: Colors.black,
          onPressed: widget.onNotificationPressed ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(),
                  ),
                );
              },
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: GestureDetector(
            onTap: widget.onProfilePressed ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserProfileScreen()),
                  );
                },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                      ? NetworkImage(_profileImageUrl!)
                      : null,
              child: _profileImageUrl == null || _profileImageUrl!.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    String? badgeText,
    bool showBadge = false,
    double iconSize = 22,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Stack(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              iconSize: iconSize,
              padding: EdgeInsets.zero,
              icon: Icon(icon, color: iconColor),
              onPressed: onPressed,
            ),
          ),
          if (badgeText != null)
            Positioned(
              right: 3,
              top: 2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          if (showBadge && badgeText == null)
            Positioned(
              right: 3,
              top: 4,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
