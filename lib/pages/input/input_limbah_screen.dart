import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:namer_app/constants.dart';

class InputLimbahScreen extends StatefulWidget {
  final int id;
  const InputLimbahScreen({super.key, required this.id});
  
  @override
  _InputLimbahScreenState createState() => _InputLimbahScreenState();
}

class _InputLimbahScreenState extends State<InputLimbahScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  List<dynamic> _limbahList = [];
  List<dynamic> _limbahJualList = [];
  String? _selectedLimbah;
  bool _isDataSaved = false;  // Menyimpan status apakah data sudah disimpan

  @override
  void initState() {
    super.initState();
    _fetchLimbah();
    _fetchLimbahJual();
  }

  Future<void> _fetchLimbah() async {
    final response = await http.get(Uri.parse('$baseUrl/limbah'));
    if (response.statusCode == 200) {
      setState(() {
        _limbahList = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load limbah');
    }
  }

  Future<void> _fetchLimbahJual() async {
    final response = await http.get(Uri.parse('$baseUrl/limbah-jual?id_toko=${widget.id}'));
    if (response.statusCode == 200) {
      setState(() {
        _limbahJualList = json.decode(response.body);
        _isDataSaved = false;  // Set data belum disimpan ketika ada data baru
      });
    } else {
      throw Exception('Failed to load limbah jual');
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final jumlah = int.tryParse(_jumlahController.text);
      final idLimbah = _selectedLimbah;
      final limbah = _limbahList.firstWhere((limbah) => limbah['id_limbah'].toString() == idLimbah);
      setState(() {
        _limbahJualList.add({
          'id_limbah': idLimbah,
          'nama_limbah': limbah['nama_limbah'],
          'jumlah': jumlah,
        });
      });
      _jumlahController.clear();
      _selectedLimbah = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Limbah berhasil ditambahkan ke daftar')),
      );
    }
  }


  Future<void> _selesaiButton() async {
    bool confirm = await _showConfirmDialog();
    if (confirm) {
      for (var item in _limbahJualList) {
        final response = await http.post(
          Uri.parse('$baseUrl/limbah-jual'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'id_limbah': item['id_limbah'],
            'jumlah': item['jumlah'],
            'id_toko': widget.id,
          }),
        );
        if (response.statusCode != 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan data untuk limbah ${item['nama_limbah']}')),
          );
          return; // Hentikan jika ada satu permintaan gagal
        }
      }

      // Jika semua data berhasil disimpan
      setState(() {
        _limbahJualList.clear(); // Bersihkan daftar setelah data disimpan
        _isDataSaved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua data berhasil disimpan')),
      );
    }
  }


  Future<bool> _showConfirmDialog() async {
  return (await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Konfirmasi'),
      content: Text('Apakah Anda yakin ingin menyelesaikan input?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Ya'),
        ),
      ],
    ),
  )) ?? false;
  }


  Future<void> _deleteItem(int idLimbah) async {
    final response = await http.delete(Uri.parse('$baseUrl/limbah-jual/$idLimbah'));
    if (response.statusCode == 200) {
      await _fetchLimbahJual();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus item')),
      );
    }
  }

  void _hapusLimbah(int index) {
  setState(() {
    _limbahJualList.removeAt(index);
  });
}


  Future<bool> _onWillPop() async {
  if (_limbahJualList.isNotEmpty && !_isDataSaved) {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Peringatan'),
        content: Text('Masih ada data input limbah yang belum disimpan. Apakah Anda ingin menyimpan atau menghapus?'),
        actions: [
          TextButton(
            onPressed: () {
              // Menghapus data input limbah ketika memilih untuk tidak menyimpan
              setState(() {
                _limbahJualList.clear(); // Kosongkan daftar input limbah
              });
              Navigator.of(context).pop(true); // Kembali ke halaman sebelumnya
            },
            child: Text('Hapus'),
          ),
          TextButton(
            onPressed: () async {
              await _selesaiButton(); // Simpan data
              Navigator.of(context).pop(true); // Kembali ke halaman sebelumnya setelah menyimpan
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    ) ?? false;
  }
  return true;
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Input Limbah', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF005ACF),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedLimbah,
                  hint: Text('Pilih Limbah'),
                  items: _limbahList.map((limbah) {
                    return DropdownMenuItem<String>(
                      value: limbah['id_limbah'].toString(),
                      child: Text(limbah['nama_limbah']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLimbah = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Nama Limbah',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF005ACF),
                      )
                    ),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Silakan pilih limbah';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan jumlah';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF005ACF),
                    ),
                    child: Text('Tambah', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Daftar Input Limbah',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _limbahJualList.length,
                    itemBuilder: (context, index) {
                      final item = _limbahJualList[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          title: Text(item['nama_limbah']),
                          subtitle: Text('Jumlah: ${item['jumlah']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _hapusLimbah(index); // Menghapus item dari daftar berdasarkan indeks
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: _selesaiButton,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF005ACF),
                    ),
                    child: Text('Simpan', style: TextStyle(fontSize: 16, color: Colors.white)),
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
