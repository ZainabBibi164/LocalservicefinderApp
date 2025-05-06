import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // Optional: for custom typography
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'DBhelper.dart';

class FinderProviderProfileScreen extends StatefulWidget {
  final String providerId;
  final Function(String, String)? onBookService;
  final bool isEmbedded;

  const FinderProviderProfileScreen({
    super.key,
    required this.providerId,
    this.onBookService,
    this.isEmbedded = false,
  });

  @override
  _FinderProviderProfileScreenState createState() => _FinderProviderProfileScreenState();
}

class _FinderProviderProfileScreenState extends State<FinderProviderProfileScreen> {
  bool _isFavorite = false;
  bool _isLoadingFavorite = true;
  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    // Trigger fade-in animation after a slight delay
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _isContentVisible = true;
      });
    });
  }

  Future<void> _checkFavoriteStatus() async {
    setState(() {
      _isLoadingFavorite = true;
    });
    bool isFav = await DatabaseHelper.instance.isFavorite(widget.providerId);
    setState(() {
      _isFavorite = isFav;
      _isLoadingFavorite = false;
    });
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite; // Update UI immediately for responsiveness
    });
    try {
      if (_isFavorite) {
        // Add to favorites
        await DatabaseHelper.instance.addFavorite(widget.providerId);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('favorites')
            .add({'providerId': widget.providerId, 'timestamp': FieldValue.serverTimestamp()});
      } else {
        // Remove from favorites
        final favorites = await DatabaseHelper.instance.getFavorites();
        final favorite = favorites.firstWhere(
              (fav) => fav['providerId'] == widget.providerId,
          orElse: () => {'id': -1},
        );
        if (favorite['id'] != -1) {
          await DatabaseHelper.instance.deleteFavorite(favorite['id']);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('favorites')
              .where('providerId', isEqualTo: widget.providerId)
              .limit(1)
              .get()
              .then((snapshot) => snapshot.docs.forEach((doc) => doc.reference.delete()));
        }
      }
    } catch (e) {
      // Revert UI state on error
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorite: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    Widget content = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal[400]!, Colors.teal[100]!],
        ),
      ),
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.providerId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[700]!),
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Provider not found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                  ),
                ),
              ),
            );
          }

          var providerData = snapshot.data!.data() as Map<String, dynamic>;

          return SafeArea(
            child: SingleChildScrollView(
              child: AnimatedOpacity(
                opacity: _isContentVisible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header with profile image
                    Stack(
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.teal[700]!, Colors.teal[400]!],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 90,
                          child: Hero(
                            tag: 'provider_image_${widget.providerId}',
                            child: CircleAvatar(
                              radius: isSmallScreen ? 60 : 80,
                              backgroundColor: Colors.teal[100],
                              child: providerData['image'] != null
                                  ? ClipOval(
                                child: Image.network(
                                  providerData['image'],
                                  width: isSmallScreen ? 120 : 160,
                                  height: isSmallScreen ? 120 : 160,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: isSmallScreen ? 60 : 80,
                                      color: Colors.teal[700],
                                    );
                                  },
                                ),
                              )
                                  : Icon(
                                Icons.person,
                                size: isSmallScreen ? 60 : 80,
                                color: Colors.teal[700],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: _isLoadingFavorite
                              ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          )
                              : AnimatedScale(
                            scale: _isFavorite ? 1.2 : 1.0,
                            duration: Duration(milliseconds: 200),
                            child: IconButton(
                              icon: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.amber[400] : Colors.white,
                                size: 32,
                              ),
                              onPressed: _toggleFavorite,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 80 : 100),
                    // Provider Details
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Text(
                            providerData['username'] ?? 'Unknown',
                            style: TextStyle(
                              // style: GoogleFonts.montserrat( // Uncomment if using google_fonts
                              fontSize: isSmallScreen ? 28 : 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            providerData['serviceType'] ?? 'Service Provider',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 20,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 24),
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.email, color: Colors.teal[700]),
                                    title: Text(
                                      providerData['email'] ?? 'N/A',
                                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                                    ),
                                  ),
                                  Divider(height: 1, color: Colors.grey[200]),
                                  ListTile(
                                    leading: Icon(Icons.phone, color: Colors.teal[700]),
                                    title: Text(
                                      providerData['phone'] ?? 'Not provided',
                                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                                    ),
                                  ),
                                  Divider(height: 1, color: Colors.grey[200]),
                                  ListTile(
                                    leading: Icon(Icons.location_on, color: Colors.teal[700]),
                                    title: Text(
                                      providerData['address'] ?? 'Not provided',
                                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          if (widget.onBookService != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () {
                                  widget.onBookService!(widget.providerId, providerData['username']);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.teal[700]!, Colors.teal[500]!],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Book Service',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    return widget.isEmbedded
        ? content
        : Scaffold(
      body: content,
    );
  }
}