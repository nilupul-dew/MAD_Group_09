import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hiking_app/data/firebase_services/notification_service.dart';
import 'package:hiking_app/presentation/screens/app_bar.dart';
import '../../widgets/groupTrip/group_trip_card.dart';
import '../../widgets/groupTrip/loading_widget.dart';
import '../../widgets/groupTrip/empty_state_widget.dart';
import '../../widgets/groupTrip/error_widget.dart';
import 'group_trip_form.dart';

class GroupTripScreen extends StatefulWidget {
  const GroupTripScreen({super.key});

  @override
  State<GroupTripScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<GroupTripScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _isSearching = _searchQuery.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
    });
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    if (_searchQuery.isEmpty) return true;

    final title = (data['title'] ?? '').toString().toLowerCase();
    final description = (data['description'] ?? '').toString().toLowerCase();
    final destination = (data['destination'] ?? '').toString().toLowerCase();

    return title.contains(_searchQuery) ||
        description.contains(_searchQuery) ||
        destination.contains(_searchQuery);
  }

  Future<void> _joinTrip(String tripId) async {
    final uid = currentUser?.uid ?? 'testUser123';

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final docRef =
          FirebaseFirestore.instance.collection('group_trips').doc(tripId);

      await docRef.update({
        'members': FieldValue.arrayUnion([uid]),
        'memberCount': FieldValue.increment(1),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined the trip!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Fetch the updated document
      final docSnapshot = await docRef.get();
      final data = docSnapshot.data();

      if (data != null) {
        String createdBy = data['createdBy'] ?? 'unknown';
        String title = data['title'] ?? 'unknown';
        List<dynamic> members = data['members'] ?? [];
        int memberCount = data['memberCount'] ?? -1;
        int maxMembers = data['maxMembers'] ?? -1;

        if (maxMembers == memberCount) {
          await NotificationService.groupTripFullNotification(
              tripId: tripId,
              tripTitle: title,
              createdBy: createdBy,
              members: members);
        } else {
          await NotificationService.memberJoinedGroupTripNotification(
              tripId: tripId,
              tripTitle: title,
              createdBy: createdBy,
              joinedUserId: uid);
        }
      }
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
      appBar: CustomAppBar(),
      body: Column(
        children: [
          // Search Bar Section
          Container(
            padding: const EdgeInsets.all(7),
            color: Colors.white,
            child: Row(
              children: [
                // Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 22),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                // Search Bar
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search groups...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search,
                            size: 22, color: Colors.grey[500]),
                        suffixIcon: _isSearching
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[500],
                                ),
                                onPressed: _clearSearch,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13.0,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Add Group Button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black, size: 22),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GroupTripForm(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          //Text
          // Text(
          //   " Group Trips",
          //   textAlign: TextAlign.left,
          //   style: GoogleFonts.montserrat(
          //     color: Color.fromARGB(239, 18, 18, 18),
          //     fontWeight: FontWeight.bold,
          //     letterSpacing: 0.5,
          //     fontSize: 22,
          //     shadows: [
          //       Shadow(
          //         offset: Offset(1.0, 1.0),
          //         blurRadius: 4.0,
          //         color: Colors.black26,
          //       ),
          //     ],
          //   ),
          // ),
          // Results Section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
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

                // Filter documents based on search query
                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _matchesSearch(data);
                }).toList();

                if (filteredDocs.isEmpty && _isSearching) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No groups found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching with different keywords',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _clearSearch,
                          child: const Text('Clear Search'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
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
          ),
        ],
      ),
    );
  }
}
