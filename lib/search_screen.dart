import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'finder_provider_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  final Function(String, String) onBook;
  final Function(String) onViewProfile;
  final Future<bool> Function(String) onCheckBooked;

  const SearchScreen({
    required this.onBook,
    required this.onViewProfile,
    required this.onCheckBooked,
  });

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal[300]!, Colors.teal[100]!],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or service...',
                prefixIcon: Icon(Icons.search, color: Colors.teal[700]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.teal[700]!, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.teal[900]!, width: 2.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('userType', isEqualTo: 'Provider')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                var providers = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String username = (data['username'] ?? '').toLowerCase();
                  String serviceType = (data['serviceType'] ?? '').toLowerCase();
                  return username.contains(_searchQuery) || serviceType.contains(_searchQuery);
                }).toList();
                if (providers.isEmpty) {
                  return Center(child: Text('No providers found'));
                }
                return ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: providers.length,
                  itemBuilder: (context, index) {
                    var provider = providers[index].data() as Map<String, dynamic>;
                    provider['uid'] = providers[index].id;

                    return FutureBuilder<bool>(
                      future: widget.onCheckBooked(provider['uid']),
                      builder: (context, bookedSnapshot) {
                        bool isBooked = bookedSnapshot.data ?? false;
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.only(bottom: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(12.0),
                            leading: provider['image'] != null
                                ? CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(provider['image']),
                              onBackgroundImageError: (error, stackTrace) {
                                print("Error loading image: ${provider['image']}, Error: $error");
                              },
                            )
                                : CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.teal[100],
                              child: Icon(Icons.person, size: 30, color: Colors.teal[700]),
                            ),
                            title: Text(
                              provider['username'] ?? 'Unknown',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                            ),
                            subtitle: Text(
                              provider['serviceType'] ?? 'N/A',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                            trailing: ElevatedButton(
                              onPressed: isBooked
                                  ? null
                                  : () {
                                widget.onBook(provider['uid'], provider['username'] ?? 'Unknown');
                              },
                              child: Text(isBooked ? 'Booked' : 'Book Service'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isBooked ? Colors.grey : Colors.teal[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            onTap: () {
                              widget.onViewProfile(provider['uid']);
                            },
                          ),
                        );
                      },
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