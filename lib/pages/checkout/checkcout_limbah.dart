import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:namer_app/constants.dart';

class CheckoutLimbah extends StatefulWidget {
  final int id;
  const CheckoutLimbah({super.key, required this.id});

  @override
  _CheckoutLimbahState createState() => _CheckoutLimbahState();
}

class _CheckoutLimbahState extends State<CheckoutLimbah> {
  Map<String, List<dynamic>> _riwayatLimbah = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRiwayatLimbah();
  }

  // Menghitung total harga untuk setiap nomor
  double _calculateTotalHargaPerNomor(List<dynamic> items) {
    double total = 0;
    for (var item in items) {
      total += item['jumlah'] * item['harga'];
    }
    return total;
  }

  // Menghitung total keseluruhan untuk semua nomor
  double _calculateTotalHargaKeseluruhan() {
    double total = 0;
    _riwayatLimbah.forEach((key, value) {
      total += _calculateTotalHargaPerNomor(value);
    });
    return total;
  }

  Future<void> _fetchRiwayatLimbah() async {
    final response = await http.get(Uri.parse('$baseUrl/data-checkout-limbah?id_toko=${widget.id}'));

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
        title: const Text(
          'Daftar Checkout Limbah',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF005ACF),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Menampilkan daftar riwayat berdasarkan nomor
                ..._riwayatLimbah.entries.map((entry) {
                  final nomor = entry.key;
                  final items = entry.value;

                  // Mengambil nama pengepul dari salah satu item, diasumsikan pengepul sama dalam 1 group nomor
                  final String namaPengepul = items.isNotEmpty ? items[0]['nama_pengepul'] : 'Unknown';
                  final double totalHargaPerNomor = _calculateTotalHargaPerNomor(items);
                  final tanggal = items[0]['tanggal'];

                  return Card(
                    elevation: 5, // Bayangan pada Card
                    margin: const EdgeInsets.all(10), // Margin pada Card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Membuat Card dengan sudut melengkung
                    ),
                    child: ExpansionTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nomor Dokumen: $nomor',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Tanggal: $tanggal',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4), // Memberi jarak kecil antara teks
                          Text(
                            'Nama Pengepul: $namaPengepul', // Ubah sesuai data toko jika tersedia
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total: Rp $totalHargaPerNomor',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green, // Menambahkan warna hijau untuk total
                            ),
                          ),
                        ],
                      ),
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const <DataColumn>[
                              DataColumn(label: Text('Limbah')),
                              DataColumn(label: Text('Jumlah')),
                              DataColumn(label: Text('Harga')),
                              DataColumn(label: Text('Sub Total')),
                            ],
                            rows: items.map((item) {
                              final int totalHargaItem = item['jumlah'] * item['harga'];
                              return DataRow(
                                cells: [
                                  DataCell(Text(item['nama_limbah'])),
                                  DataCell(Text(item['jumlah'].toString())),
                                  DataCell(Text(item['harga'].toString())),
                                  DataCell(Text(totalHargaItem.toString())),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
    );
  }
}
