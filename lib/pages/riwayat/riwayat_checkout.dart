import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // For file operations
import 'package:file_picker/file_picker.dart';
import 'package:namer_app/constants.dart'; // Add file_picker package for file selection

class RiwayatCheckoutLimbah extends StatefulWidget {
  final int id;
  const RiwayatCheckoutLimbah({super.key, required this.id});

  @override
  _RiwayatCheckoutLimbahState createState() => _RiwayatCheckoutLimbahState();
}

class _RiwayatCheckoutLimbahState extends State<RiwayatCheckoutLimbah> {
  Map<String, List<dynamic>> _riwayatLimbah = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRiwayatLimbah();
  }

  double _calculateTotalHargaPerNomor(List<dynamic> items) {
    double total = 0;
    for (var item in items) {
      total += item['jumlah'] * item['harga'];
    }
    return total;
  }

  double _calculateTotalHargaKeseluruhan() {
    double total = 0;
    _riwayatLimbah.forEach((key, value) {
      total += _calculateTotalHargaPerNomor(value);
    });
    return total;
  }

  Future<void> _fetchRiwayatLimbah() async {
    final response = await http.get(Uri.parse('$baseUrl/data-checkout-limbah-pengepul?id_pengepul=${widget.id}'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final Map<String, List<dynamic>> groupedData = {};
      for (var item in data) {
        final nomor = item['nomor'].toString();
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

  // Function to handle file picking and uploading
  Future<void> _uploadBukti(String nomor, int idPengepul) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    File file = File(result.files.single.path!);
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload-bukti'),
    );
    request.fields['nomor'] = nomor;
    request.fields['id_pengepul'] = idPengepul.toString(); // Mengirim id_pengepul
    request.files.add(
      await http.MultipartFile.fromPath('bukti', file.path),
    );

    var response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bukti uploaded successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload bukti')),
      );
    }
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Checkout Limbah',
          style: TextStyle(
            color: Color.fromARGB(255, 251, 251, 251),
          ),
        ),
        backgroundColor: Color(0xFF005ACF),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ..._riwayatLimbah.entries.map((entry) {
                  final nomor = entry.key;
                  final items = entry.value;

                  final String namaToko = items.isNotEmpty ? items[0]['nama_toko'] : 'Unknown';
                  final int status = items.isNotEmpty ? items[0]['status'] : 'Unknown';
                  final double totalHargaPerNomor = _calculateTotalHargaPerNomor(items);

                  final tanggal = items[0]['tanggal'];

                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
                          const SizedBox(height: 4),
                          Text(
                            'Tanggal: $tanggal',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nama Toko: $namaToko',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total: Rp $totalHargaPerNomor',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                            Text(
                              'Status: ${status == 2 ? 'Sedang Proses' : status == 3 ? 'Berhasil' : 'Unknown Status'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: status == 3 ? Colors.green : Colors.orange, // Warna hijau untuk Berhasil, oranye untuk Sedang Proses
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
                              DataColumn(label: Text('SubTotal')),
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            onPressed: () => _uploadBukti(nomor,widget.id), // Call upload function with nomor
                            icon: const Icon(Icons.upload_file, color: Colors.white,),
                            label: Text('Upload Bukti', 
                              style: TextStyle(
                                color: Color.fromARGB(255, 247, 247, 247),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF005ACF),
                            ),
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
