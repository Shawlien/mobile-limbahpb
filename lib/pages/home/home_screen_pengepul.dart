import 'package:flutter/material.dart';
import 'package:namer_app/pages/checkout/checkout_screen.dart';
import 'package:namer_app/pages/riwayat/riwayat_checkout.dart';

class PengepulDashboard extends StatelessWidget {
  final int id;
  const PengepulDashboard({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dasboard Pengepul',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildCard(
                      context,
                      title: 'Checkout',
                      description: 'Lihat dan kelola transaksi checkout.',
                      icon: Icons.check_circle,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(id: id),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    _buildCard(
                      context,
                      title: 'Riwayat Checkout',
                      description: 'Lihat riwayat transaksi checkout.',
                      icon: Icons.history,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RiwayatCheckoutLimbah(id: id),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required String description,
      required IconData icon,
      required VoidCallback onTap}) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(20),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 40, color: Colors.blueAccent),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(color: Colors.grey.shade700),
        ),
        onTap: onTap,
      ),
    );
  }
}
