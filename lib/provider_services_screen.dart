import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'provider_bottom_navigation.dart';

class ProviderServicesScreen extends StatefulWidget {
  final String providerType;

  const ProviderServicesScreen({super.key, required this.providerType});

  @override
  _ProviderServicesScreenState createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  int _currentIndex = 3;
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allServices = [];
  List<Map<String, dynamic>> filteredServices = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterServices);
  }

  void _filterServices() {
    setState(() {
      filteredServices = allServices.where((service) {
        final name = service['name'].toLowerCase();
        return name.contains(searchController.text.toLowerCase());
      }).toList();
    });
  }

  void _onTabTapped(int index, String? providerId, String? providerName) {
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
        route = '/provider_services';
        break;
      case 4:
        route = '/provider_history';
        break;
      default:
        return;
    }
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await FirebaseFirestore.instance.collection('services').doc(serviceId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete service: $e')),
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.providerType} Services'),
        backgroundColor: Colors.teal[700],
        elevation: 2,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search your services...',
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('services')
                    .where('providerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .where('providerType', isEqualTo: widget.providerType)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No services found.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/add_service');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: const Text('Add a New Service'),
                          ),
                        ],
                      ),
                    );
                  }

                  allServices = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {
                      'id': doc.id,
                      'name': data['title'] ?? 'Untitled',
                      'type': data['providerType'] ?? 'Unknown',
                      'status': data['status'] ?? 'Active',
                      'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
                      'locations': List<String>.from(data['locations'] ?? []),
                      'completedWork': (data['completedWork'] as num?)?.toInt() ?? 0,
                    };
                  }).toList();

                  _filterServices();

                  if (filteredServices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            searchController.text.isEmpty
                                ? 'No services found.'
                                : 'No services match your search.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/add_service');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: const Text('Add a New Service'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = filteredServices[index];
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
                              const SizedBox(height: 4),
                              Text(
                                'Locations: ${service['locations'].isNotEmpty ? service['locations'].join(", ") : 'Not specified'}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                'Completed Tasks: ${service['completedWork']}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.teal),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Edit service functionality to be implemented')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Service'),
                                      content: const Text('Are you sure you want to delete this service?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await deleteService(service['id']);
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onIndexChanged: _onTabTapped,
        userType: 'Provider',
      ),
    );
  }
}