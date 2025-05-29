// lib/presentation/screens/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
import 'package:hiking_app/data/firebase_services/item/checkout_firestore_service.dart';
import 'package:hiking_app/presentation/screens/home_screen.dart';
import 'package:hiking_app/presentation/screens/item/card_input_page.dart'; // Import your Firestore service

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? _selectedPaymentMethod;
  final CheckoutFirestoreService _firestoreService = CheckoutFirestoreService();

  // Variable to hold the current authenticated user
  User? _currentUser;

  // Dummy data for order items and total amount
  // In a real app, this would come from a shopping cart model/provider
  final List<Map<String, dynamic>> _dummyItems = [
    {'name': 'Hiking Boots', 'price': 120.0, 'qty': 1},
    {'name': 'Backpack', 'price': 50.0, 'qty': 1},
    {'name': 'Water Bottle', 'price': 15.0, 'qty': 2},
  ];
  final double _dummyTotalAmount = 200.0; // 120 + 50 + (15*2) = 200

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // Call this to get the user ID when the page initializes
  }

  // Method to get the current Firebase authenticated user
  void _loadCurrentUser() {
    // FirebaseAuth.instance.currentUser gives you the currently signed-in user.
    // It will be null if no user is signed in.
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser == null) {
      print('DEBUG: No user logged in. Orders will use a fallback ID.');
      // In a production app, you might want to redirect to a login page here
      // or show a persistent message prompting the user to sign in.
    } else {
      print('DEBUG: Current user ID: ${_currentUser!.uid}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildDeliveryOption(
                    icon: Icons.location_on_outlined,
                    text: 'Delivery Address',
                  ),
                  const SizedBox(height: 10),
                  _buildDeliveryOption(
                    icon: Icons.my_location_outlined,
                    text: 'Delivery to your current location',
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Payment Methods',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentMethodOption(
                    value: 'Credit / Debit Card',
                    icon:
                        'assets/images/card_icon.png', // Ensure this path is correct
                    text: 'Credit / Debit Card',
                    isClickable: true, // Make this clickable
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentMethodOption(
                    value: 'Google Pay',
                    icon:
                        'assets/images/google_pay_icon.png', // Ensure this path is correct
                    text: 'Google Pay',
                    isClickable: false, // Make this NOT clickable
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Other',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentMethodOption(
                    value: 'Cash On Delivery',
                    icon:
                        'assets/images/cash_delivery_icon.jpg', // Ensure this path is correct
                    text: 'Cash On Delivery',
                    isClickable: true, // Make this clickable
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentMethodOption(
                    value: 'Partial Payment',
                    icon:
                        'assets/images/partial_payment_icon.png', // Ensure this path is correct
                    text: 'Partial Payment',
                    isClickable: false, // Make this NOT clickable
                  ),
                ],
              ),
            ),
          ),
          // Pay Button at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _handlePayment(); // Call the payment handling logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.deepOrange, // Orange color for the button
                minimumSize: const Size(
                  double.infinity,
                  50,
                ), // Full width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // Rounded corners for the button
                ),
              ),
              child: const Text(
                'Pay',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Payment Handling Logic ---
  void _handlePayment() async {
    // Made async because Firestore operations are async
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return;
    }

    print('Pay button pressed!');
    print('Selected Payment Method: $_selectedPaymentMethod');

    // Get the user ID. If no user is logged in, use a placeholder.
    String userIdToUse = _currentUser?.uid ?? 'anonymous_user';

    switch (_selectedPaymentMethod) {
      case 'Cash On Delivery':
        try {
          await _firestoreService.addOrder(
            userId: userIdToUse,
            selectedPaymentMethod: 'Cash On Delivery',
            totalAmount: _dummyTotalAmount, // Pass actual total
            items: _dummyItems, // Pass actual items
            deliveryAddress:
                '123 Main St, Anytown, USA', // Replace with actual delivery address
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Order placed successfully! Pay on delivery. (Saved to Firestore)',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const HomeScreen()), // Navigate to HomeScreen
            (Route<dynamic> route) =>
                false, // This condition removes all routes below the new one
          );
        } catch (e) {
          // Handle any errors from Firestore (e.g., network issues, permission errors)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to place order: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
      case 'Credit / Debit Card':
        // Navigate to the CardInputPage.
        // In a real app, after the card input, you'd process payment
        // via a payment gateway and then save the order to Firestore.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CardInputPage()),
        );
        // Optionally, you could also save a 'pending' order to Firestore here,
        // and update its status to 'paid' after successful payment gateway response.
        break;
      case 'Google Pay':
      case 'Partial Payment':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$_selectedPaymentMethod is not currently active for demo.',
            ),
            backgroundColor: Colors.red, // Indicating not available
          ),
        );
        print(
          'Attempted to select inactive payment method: $_selectedPaymentMethod',
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment method "$_selectedPaymentMethod" selected.'),
          ),
        );
        break;
    }
  }

  Widget _buildDeliveryOption({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required String value,
    required String icon,
    required String text,
    bool isClickable = true, // NEW: Added a parameter to control clickability
  }) {
    Widget iconWidget;
    try {
      iconWidget = Image.asset(icon, width: 24, height: 24);
    } catch (e) {
      iconWidget = const Icon(Icons.error_outline, size: 24, color: Colors.red);
      print("Error loading asset $icon: $e");
    }

    return GestureDetector(
      // NEW: Conditionally set onTap
      onTap: isClickable
          ? () {
              setState(() {
                _selectedPaymentMethod = value;
              });
            }
          : null, // If not clickable, onTap is null
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          // NEW: Adjust border color to indicate non-clickability
          border: Border.all(
            color: _selectedPaymentMethod == value && isClickable
                ? Colors.blue // Highlight selected clickable option
                : isClickable
                    ? Colors.grey.shade300 // Normal clickable option
                    : Colors.grey.shade400, // Dimmed for non-clickable
            width: _selectedPaymentMethod == value && isClickable ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // NEW: Dim the icon if not clickable
            Opacity(opacity: isClickable ? 1.0 : 0.5, child: iconWidget),
            const SizedBox(width: 10),
            Expanded(
              child:
                  // NEW: Dim the text if not clickable
                  Opacity(
                opacity: isClickable ? 1.0 : 0.5,
                child: Text(
                  text,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // NEW: Only show checkmark if selected AND clickable
            if (_selectedPaymentMethod == value && isClickable)
              const Icon(Icons.check_circle, color: Colors.blue),
            // Optional: Add an "X" or "Coming Soon" icon for non-clickable
            if (!isClickable)
              const Icon(Icons.do_not_disturb_alt, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
