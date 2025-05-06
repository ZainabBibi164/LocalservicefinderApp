import 'package:flutter/material.dart';
import 'provider_bottom_navigation.dart';

class ProviderHistoryScreen extends StatefulWidget {
  const ProviderHistoryScreen({super.key});

  @override
  _ProviderHistoryScreenState createState() => _ProviderHistoryScreenState();
}

class _ProviderHistoryScreenState extends State<ProviderHistoryScreen> {
  int _currentIndex = 3; // Set to 4 for the "history" tab

  // Dummy data for recent services
  final List<Map<String, dynamic>> recentServices = [
    {
      'id': '1',
      'name': 'Electrical Wiring',
      'type': 'Electrician',
      'date': '2025-04-20',
      'location': 'New York, NY',
      'status': 'Completed',
      'rating': 4.5,
    },
    {
      'id': '2',
      'name': 'Plumbing Repair',
      'type': 'Plumber',
      'date': '2025-04-15',
      'location': 'Los Angeles, CA',
      'status': 'Completed',
      'rating': 4.0,
    },
    {
      'id': '3',
      'name': 'Circuit Breaker Installation',
      'type': 'Electrician',
      'date': '2025-04-10',
      'location': 'Chicago, IL',
      'status': 'Completed',
      'rating': 5.0,
    },
  ];

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
      appBar: AppBar(
        title: const Text('Service History'),
        backgroundColor: Colors.teal[700],
        elevation: 2,
      ),
      body: Container(
        color: Colors.grey[100],
        child: recentServices.isEmpty
            ? Center(
          child: Text(
            'No recent services found.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: recentServices.length,
          itemBuilder: (context, index) {
            final service = recentServices[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(
                  service['type'] == 'Electrician'
                      ? Icons.electrical_services
                      : Icons.plumbing,
                  color: Colors.teal,
                  size: 30,
                ),
                title: Text(
                  service['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Date: ${service['date']}'),
                    Text('Location: ${service['location']}'),
                    Text('Status: ${service['status']}'),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < service['rating'].toInt()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
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