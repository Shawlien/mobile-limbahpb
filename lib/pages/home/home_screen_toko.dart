import 'package:flutter/material.dart';
import '../checkout/checkcout_limbah.dart';
import '../input/input_limbah_screen.dart';
import '../riwayat/riwayat_screen.dart';

class HomeScreenToko extends StatelessWidget {
  final int id;
  const HomeScreenToko({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dasboard Toko',
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF005ACF),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF005ACF)
        ),
        child: SingleChildScrollView( // Tambahkan SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                'Selamat Datang',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: Colors.black45,
                        ),
                      ],
                    ),
              ),
                SizedBox(height: 14,),
                // Card for Input Limbah
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.white.withOpacity(0.9),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InputLimbahScreen(id: id),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.input, size: 50, color: Colors.blue),
                            SizedBox(height: 10),
                            Text(
                              'Input Limbah',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Masukkan data limbah yang baru.',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20), // Space between the cards

                // Card for Riwayat Input Limbah
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.white.withOpacity(0.9),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RiwayatScreen(id: id),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.history, size: 50, color: Colors.deepOrange),
                            SizedBox(height: 10),
                            Text(
                              'Riwayat Input Limbah',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange.shade700,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Lihat riwayat data limbah yang sudah diinput.',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20), // Space between the cards

                // Card for Checkout Limbah
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.white.withOpacity(0.9),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutLimbah(id: id),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.money, size: 50, color: Colors.greenAccent.shade700),
                            SizedBox(height: 10),
                            Text(
                              'Checkout Limbah',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Lihat limbah yang sudah di checkout oleh pengepul.',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
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
