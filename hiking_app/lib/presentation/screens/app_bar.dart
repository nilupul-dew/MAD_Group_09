import 'package:flutter/material.dart';
import 'package:hiking_app/presentation/screens/item/cart_page.dart';
import 'package:hiking_app/presentation/screens/user/user_profile_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int cartItemCount;
  final VoidCallback? onCartPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final ValueChanged<String>? onSearchChanged;

  const CustomAppBar({
    Key? key,
    this.cartItemCount = 0,
    this.onCartPressed,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.onSearchChanged,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset('assets/images/logo1.png', height: 90),
          RichText(
            text: TextSpan(
              text: "CAMP",
              style: TextStyle(
                color: const Color.fromARGB(255, 238, 97, 3),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              children: [
                TextSpan(
                  text: "SITE",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 18, 18, 18),
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
        Padding(
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
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.shopping_cart_outlined),
                  onPressed: onCartPressed ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartScreen(),
                          ),
                        );
                      },
                ),
              ),
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
                      '$cartItemCount', //TODO add cart count
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
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
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.notifications_none),
                  onPressed: onNotificationPressed,
                ),
              ),
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
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
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
              iconSize: 30,
              padding: EdgeInsets.zero,
              icon: Icon(Icons.account_circle_rounded),
              onPressed: onProfilePressed ??
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(),
                      ),
                    );
                  },
            ),
          ),
        ),
      ],
    );
  }
}
