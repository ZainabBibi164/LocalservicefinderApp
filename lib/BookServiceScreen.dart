import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookServiceScreen extends StatefulWidget {
  final String? providerId;
  final String? providerName;

  const BookServiceScreen({super.key, this.providerId, this.providerName});

  @override
  _BookServiceScreenState createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  bool _isBooked = false;
  final TextEditingController _messageController = TextEditingController();

  Future<void> _bookService() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to book a service')),
        );
        return;
      }

      // Create a booking in Firestore
      DocumentReference bookingRef = await FirebaseFirestore.instance.collection('bookings').add({
        'finderId': currentUser.uid,
        'providerId': widget.providerId,
        'providerName': widget.providerName,
        'message': _messageController.text,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Create a notification for the provider
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': widget.providerId,
        'type': 'booking_request',
        'message': 'You have a new booking request from ${currentUser.email ?? 'a user'}.',
        'bookingId': bookingRef.id,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      setState(() {
        _isBooked = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent to provider successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking service: $e')),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.providerId == null || widget.providerName == null) {
      return const Center(child: Text('Select a provider to book a service.'));
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal[300]!, Colors.teal[100]!],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.book_online,
                              color: Colors.teal,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Book a Service with ${widget.providerName}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _messageController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Your Message (Optional)',
                            labelStyle: TextStyle(color: Colors.grey[700]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: ElevatedButton(
                            onPressed: _isBooked ? null : _bookService,
                            child: Text(
                              _isBooked ? 'Booked' : 'Book Service',
                              style: const TextStyle(fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: _isBooked ? Colors.grey[400] : Colors.teal[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}