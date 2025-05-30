import 'package:flutter/material.dart';
import 'package:hiking_app/domain/models/sos/emergency_contact.dart';

class ContactRow extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onDelete;

  const ContactRow({required this.contact, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2D3436),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  contact.phoneNumber,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF636E72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Color(0xFFFF7675),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.remove, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
