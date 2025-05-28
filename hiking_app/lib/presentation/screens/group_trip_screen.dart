import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../presentation/widgets/group_trip_card.dart';
import '../../presentation/widgets/loading_widget.dart';
import '../../presentation/widgets/empty_state_widget.dart';
import '../../presentation/widgets/error_widget.dart';
import '../../presentation/screens/group_trip_form.dart';

class GroupTripScreen extends StatefulWidget {
  const GroupTripScreen({super.key});

  @override
  State<GroupTripScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<GroupTripScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _joinTrip(String tripId) async {
    final uid = currentUser?.uid ?? 'testUser123';

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await FirebaseFirestore.instance
          .collection('group_trips')
          .doc(tripId)
          .update({
            'members': FieldValue.arrayUnion([uid]),
            'memberCount': FieldValue.increment(1),
          });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Successfully joined the trip!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      print('Join error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to join trip: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = currentUser?.uid ?? 'testUser123';

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Group Trips'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Group',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GroupTripForm()),
                );
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('group_trips')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return CustomErrorWidget(error: snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyStateWidget();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final members = List<String>.from(data['members'] ?? []);

              return GroupTripCard(
                data: data,
                members: members,
                userId: userId,
                tripId: doc.id,
                joinTrip: _joinTrip,
              );
            },
          );
        },
      ),
    );
  }
}
