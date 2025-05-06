import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

typedef void IndexCallback(int index, String? providerId, String? providerName);

class BottomNavigation extends StatefulWidget {
  final int currentIndex;
  final String userType;
  final String? providerId;
  final String? providerName;
  final IndexCallback? onIndexChanged;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.userType,
    this.providerId,
    this.providerName,
    this.onIndexChanged,
  });

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  void _onItemTapped(int index, BuildContext context) async {
    if (widget.userType == 'Finder') {
      if (index == 4) {
        bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Log Out', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      if (widget.onIndexChanged != null) {
        String? providerId = widget.providerId;
        String? providerName = widget.providerName;

        widget.onIndexChanged!(index, providerId, providerName);
      }
    } else if (widget.userType == 'Provider') {
      String? route;
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
          route = '/provider_services';
          break;
      }
      if (route != null) {
        Navigator.pushReplacementNamed(context, route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> items = [];

    if (widget.userType == 'Finder') {
      items = [
        const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        const BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Bookings'),
        const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        const BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: 'Exit'),
      ];
    } else if (widget.userType == 'Provider') {
      items = [
        const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        const BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Service'),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        const BottomNavigationBarItem(icon: Icon(Icons.build), label: 'My Services'),
      ];
    }

    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: (index) => _onItemTapped(index, context),
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: items,
    );
  }
}