// lib/presentation/widgets/quantity_selector.dart
import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const QuantitySelector({
    Key? key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // To keep the row compact
      children: [
        _buildButton(
          icon: Icons.remove,
          onPressed: onDecrement,
          isEnabled: quantity > 1, // Disable decrement if quantity is 1
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '$quantity',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        _buildButton(
          icon: Icons.add,
          onPressed: onIncrement,
          isEnabled: true, // Always allow increment (Firestore will handle stock check)
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isEnabled,
  }) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isEnabled ? Colors.grey[200] : Colors.grey[300], // Visual feedback for disabled
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: isEnabled ? onPressed : null, // Disable onTap if not enabled
        child: Icon(
          icon,
          size: 20,
          color: isEnabled ? Colors.black : Colors.grey[500], // Grey out icon if disabled
        ),
      ),
    );
  }
}