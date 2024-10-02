import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:namer_app/constants.dart';

class RiwayatScreen extends StatefulWidget {
  final int id;
  const RiwayatScreen({super.key, required this.id});
  @override
  _RiwayatScreenState createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  Map<String, List<dynamic>> _riwayatLimbah = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRiwayatLimbah();
  }

  Future<void> _fetchRiwayatLimbah() async {
    final response = await http.get(Uri.parse('$baseUrl/riwayat-input-limbah?id_toko=${widget.id}'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // Mengelompokkan data berdasarkan nomor
      final Map<String, List<dynamic>> groupedData = {};
      for (var item in data) {
        final nomor = item['nomor'].toString(); // Mengelompokkan berdasarkan nomor
        if (!groupedData.containsKey(nomor)) {
          groupedData[nomor] = [];
        }
        groupedData[nomor]!.add(item);
      }

      setState(() {
        _riwayatLimbah = groupedData;
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load riwayat limbah');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Input Limbah', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF005ACF),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: _riwayatLimbah.entries.map((entry) {
                final nomor = entry.key;
                final items = entry.value;
                final tanggal = items[0]['tanggal'];
             
                return Card(
                  elevation: 5, // Membuat bayangan pada card agar lebih menarik
                  margin: EdgeInsets.all(10), // Memberikan margin pada setiap card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Membuat sudut card melengkung
                  ),
                  child: ExpansionTile(
                    title: Text('Nomor Dokumen: $nomor', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Tanggal Input: $tanggal'),
                    children: items.map((item) {
                      return ListTile(
                        leading: Icon(Icons.recycling, color: Colors.green), // Icon untuk menambah daya tarik
                        title: Text(
                          'Nama Limbah: ${item['nama_limbah']} (${item['satuan']})',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text('Jumlah: ${item['jumlah']}'),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
