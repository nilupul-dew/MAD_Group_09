import 'package:flutter/material.dart';
import 'package:hiking_app/presentation/screens/item/cart_page.dart';
import 'package:hiking_app/presentation/screens/user/user_profile_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int cartItemCount;
  final VoidCallback? onCartPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final ValueChanged<String>? onSearchChanged;
  final Widget? leading;
  final Widget? title;
  const CustomAppBar({
    Key? key,
    this.cartItemCount = 0,
    this.onCartPressed,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.onSearchChanged,
    this.leading,
    this.title,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset('assets/images/logo1.png', height: 50), // Reduced from 90
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              text: "CAMP",
              style: TextStyle(
                color: Color.fromARGB(255, 238, 97, 3),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              children: [
                TextSpan(
                  text: "SITE",
                  style: TextStyle(
                    color: Color.fromARGB(255, 18, 18, 18),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _buildIconButton(
          icon: Icons.shopping_cart_outlined,
          onPressed: onCartPressed ??
              () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => CartScreen()));
              },
          badgeText: '$cartItemCount',
        ),
        _buildIconButton(
          icon: Icons.notifications_none,
          onPressed: onNotificationPressed,
          showBadge: true,
        ),
        _buildIconButton(
          icon: Icons.account_circle_rounded,
          iconSize: 30,
          onPressed: onProfilePressed ??
              () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => UserProfileScreen()));
              },
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
              icon: Icon(icon),
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
