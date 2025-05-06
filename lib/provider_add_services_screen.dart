import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  _AddServiceScreenState createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String price = '';
  String status = 'Available';
  int rating = 0;
  List<String> locations = [];
  String locationInput = '';
  String providerType = 'Electrician';
  bool isLoading = false;
  final List<String> providerTypes = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Painter',
    'Cleaner'
  ];

  Future<void> addServiceToFirestore() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to add a service')),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('services').add({
          'title': title,
          'description': description,
          'price': double.parse(price),
          'status': status,
          'rating': rating,
          'locations': locations,
          'providerType': providerType,
          'providerId': currentUser.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service added successfully!')),
        );
        Navigator.pushReplacementNamed(
          context,
          '/provider_dashboard',
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding service: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Service'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Service Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter service title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    title = value ?? '';
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    description = value ?? '';
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    price = value ?? '';
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: providerType,
                  items: providerTypes
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      providerType = value ?? 'Electrician';
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Provider Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a provider type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Locations (comma-separated)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  onChanged: (value) {
                    locationInput = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter at least one location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  items: ['Available', 'Unavailable']
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      status = value ?? 'Available';
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    locations = locationInput
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                    addServiceToFirestore();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Add Service'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}