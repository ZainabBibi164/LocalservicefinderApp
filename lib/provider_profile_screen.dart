import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';
import 'provider_bottom_navigation.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  _ProviderProfileScreenState createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  int _currentIndex = 2; // Set to 2 for the "profile" tab

  void onTabTapped(int index, String? providerId, String? providerName) {
    if (index == _currentIndex) return; // Prevent re-navigation to same page
    setState(() {
      _currentIndex = index;
    });

    String route;
    switch (index) {
      case 0:
        route = '/provider_dashboard';
        break;
      case 1:
        route = '/add_service';
        break;
      case 2:
        route = '/provider_profile';
        break;
      case 3:
        route = '/provider_history';
        break;
      default:
        return;
    }
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Please log in to view your profile')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[700],
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal[300]!, Colors.teal[100]!],
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Profile not found'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return Padding(
              padding: EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.teal[100],
                      child: userData['image'] != null
                          ? ClipOval(
                        child: Image.network(
                          userData['image'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, size: 50, color: Colors.teal[700]);
                          },
                        ),
                      )
                          : Icon(Icons.person, size: 50, color: Colors.teal[700]),
                    ),
                    SizedBox(height: 16),
                    Text(
                      userData['username'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      userData['serviceType'] ?? 'Service Provider',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 24),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contact Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[700],
                              ),
                            ),
                            SizedBox(height: 12),
                            ListTile(
                              leading: Icon(Icons.phone, color: Colors.teal[700]),
                              title: Text(
                                userData['phone'] ?? 'Not provided',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.location_on, color: Colors.teal[700]),
                              title: Text(
                                userData['address'] ?? 'Not provided',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(userData: userData),
                          ),
                        );
                      },
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 18, color: Colors.teal[700]),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onIndexChanged: onTabTapped,
        userType: 'Provider',
      ),
    );
  }
}