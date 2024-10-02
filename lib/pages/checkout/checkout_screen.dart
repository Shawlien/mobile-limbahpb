import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:namer_app/constants.dart';

class CheckoutScreen extends StatefulWidget {
  final int id;
  const CheckoutScreen({super.key, required this.id});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<dynamic> _limbahJualList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLimbahJual();
  }

  Future<void> _fetchLimbahJual() async {
    final response = await http.get(Uri.parse('$baseUrl/checkout-pengepul?id_pengepul=${widget.id}'));
    if (response.statusCode == 200) {
      setState(() {
        _limbahJualList = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load limbah jual');
    }
  }

  void _checkout() async {
    final Map<String, dynamic> requestBody = {
      'id_pengepul': widget.id,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/checkout-proses'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout berhasil!')),
      );
      await _fetchLimbahJual();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memproses checkout')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Check Out Limbah',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF005ACF),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _limbahJualList.length,
                      itemBuilder: (context, index) {
                        final item = _limbahJualList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: Icon(
                              Icons.recycling,
                              size: 50,
                              color: Colors.green,
                            ),
                            title: Text(
                              item['nama_limbah'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Jumlah: ${item['jumlah']}\nNomor: ${item['nomor']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: _checkout,
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text(
                        'Checkout',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: Colors.blue, // Background color
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
