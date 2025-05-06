import 'package:flutter/material.dart';

typedef IndexCallback = void Function(int index, String? providerId, String? providerName);

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final IndexCallback? onIndexChanged;
  final String userType;
  final String? providerId;
  final String? providerName;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.userType,
    this.providerId,
    this.providerName,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onIndexChanged != null
          ? (index) => onIndexChanged!(index, providerId, providerName)
          : null,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.teal[700],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.teal[100],
      items: userType == 'Finder'
          ? const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Book',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
      ]
          : const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_business),
          label: 'Add Service',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
      ],
    );
  }
}