import 'package:flutter/material.dart';
import 'provider_bottom_navigation.dart';

class ProviderDashboardScreen extends StatefulWidget {
  final String? providerId;

  const ProviderDashboardScreen({super.key, this.providerId});

  @override
  _ProviderDashboardScreenState createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  int _currentIndex = 0;
  String providerType = 'Electrician';

  void onTabTapped(int index, String? providerId, String? providerName) {
    if (index == _currentIndex) return;
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Provider Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[700]!, Colors.teal[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/provider_profile'),
                      icon: const Icon(Icons.person),
                      label: const Text('View/Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/add_service'),
                      icon: const Icon(Icons.add_business),
                      label: const Text('Add New Service'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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