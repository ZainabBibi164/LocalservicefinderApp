import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_screen.dart';
import 'BookServiceScreen.dart';
import 'finder_provider_profile_screen.dart';
import 'bottom_navigation.dart';
import 'edit_profile_screen.dart';

class FinderHomeScreen extends StatefulWidget {
  final String? providerId;
  final String? providerName;

  const FinderHomeScreen({this.providerId, this.providerName});

  static _FinderHomeScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<_FinderHomeScreenState>();
  }

  @override
  _FinderHomeScreenState createState() => _FinderHomeScreenState();
}

class _FinderHomeScreenState extends State<FinderHomeScreen> {
  int _selectedIndex = 0;
  String? _providerId;
  String? _providerName;
  String? _selectedProviderId;

  @override
  void initState() {
    super.initState();
    _providerId = widget.providerId;
    _providerName = widget.providerName;
  }

  String? get providerId => _providerId;
  String? get providerName => _providerName;

  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0:
        return SearchScreen(
          onBook: (providerId, providerName) {
            setState(() {
              _providerId = providerId;
              _providerName = providerName;
              _selectedIndex = 2;
              _selectedProviderId = null;
            });
          },
          onViewProfile: (providerId) {
            setState(() {
              _selectedProviderId = providerId;
              _providerId = null;
              _providerName = null;
            });
          },
          onCheckBooked: (providerId) async {
            String finderId = FirebaseAuth.instance.currentUser!.uid;
            var bookedSnapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(finderId)
                .collection('bookings')
                .where('providerId', isEqualTo: providerId)
                .limit(1)
                .get();
            return bookedSnapshot.docs.isNotEmpty;
          },
        );
      case 1:
        return _buildProfileTab();
      case 2:
        return BookServiceScreen(providerId: _providerId, providerName: _providerName);
      case 3:
        return _buildFavoritesTab();
      case 4:
        return _buildBookingsTab();
      default:
        return Container();
    }
  }

  Widget _buildProfileTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal[300]!, Colors.teal[100]!],
        ),
      ),
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Profile not found'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          userData['uid'] = snapshot.data!.id;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: userData['image'] != null
                            ? CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(userData['image']),
                          onBackgroundImageError: (error, stackTrace) {
                            print("Error loading image: ${userData['image']}, Error: $error");
                          },
                        )
                            : CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.teal[100],
                          child: Icon(Icons.person, size: 50, color: Colors.teal[700]),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Username: ${userData['username'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Email: ${userData['email'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Phone: ${userData['phone'] ?? 'Not provided'}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Address: ${userData['address'] ?? 'Not provided'}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(userData: userData),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        child: Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Colors.teal[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text('Go to Login Page'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal[300]!, Colors.teal[100]!],
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          var favorites = snapshot.data!.docs;
          if (favorites.isEmpty) {
            return Center(child: Text('No favorite providers yet'));
          }
          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              var favorite = favorites[index].data() as Map<String, dynamic>;
              String providerId = favorite['providerId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(providerId).get(),
                builder: (context, providerSnapshot) {
                  if (!providerSnapshot.hasData) return SizedBox.shrink();
                  var provider = providerSnapshot.data!.data() as Map<String, dynamic>?;
                  if (provider == null) return SizedBox.shrink();

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
                      onTap: () {
                        setState(() {
                          _selectedProviderId = providerId;
                          _selectedIndex = 0;
                          _providerId = null;
                          _providerName = null;
                        });
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.favorite, color: Colors.amber[600]),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('favorites')
                              .doc(favorites[index].id)
                              .delete();
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingsTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal[300]!, Colors.teal[100]!],
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('bookings')
            .orderBy('timestamp', descending: true) // Sort by timestamp (recent first)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          var bookings = snapshot.data!.docs;
          if (bookings.isEmpty) {
            return Center(child: Text('No bookings yet'));
          }
          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index].data() as Map<String, dynamic>;
              String providerId = booking['providerId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(providerId).get(),
                builder: (context, providerSnapshot) {
                  if (!providerSnapshot.hasData) return SizedBox.shrink();
                  var provider = providerSnapshot.data!.data() as Map<String, dynamic>?;
                  if (provider == null) return SizedBox.shrink();

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
                      trailing: Text(
                        booking['status'] ?? 'Pending',
                        style: TextStyle(fontSize: 14, color: Colors.teal[700]),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _providerId = args['providerId'];
        _providerName = args['providerName'];
        _selectedProviderId = args['selectedProviderId'];
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 && _selectedProviderId != null
              ? 'Provider Profile'
              : _selectedIndex == 1
              ? 'My Profile'
              : _selectedIndex == 2 && _providerName != null
              ? 'Book Service with $_providerName'
              : _selectedIndex == 2
              ? 'Book Service'
              : _selectedIndex == 3
              ? 'Favorites'
              : _selectedIndex == 4
              ? 'Bookings'
              : 'Search',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal[700],
        elevation: 0,
      ),
      body: _selectedIndex == 0 && _selectedProviderId != null
          ? FinderProviderProfileScreen(providerId: _selectedProviderId!)
          : _getScreen(),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedIndex,
        userType: 'Finder',
        onIndexChanged: (index, providerId, providerName) {
          setState(() {
            _selectedIndex = index;
            if (index != 2) {
              _providerId = null;
              _providerName = null;
            }
            if (index != 0) {
              _selectedProviderId = null;
            }
          });
        },
      ),
    );
  }
}