import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HalamanUtamaUser(),
    ),
  );
}

class HalamanUtamaUser extends StatefulWidget {
  const HalamanUtamaUser({super.key});

  @override
  State<HalamanUtamaUser> createState() => _HalamanUtamaUserState();
}

class _HalamanUtamaUserState extends State<HalamanUtamaUser> {
  final List<String> kota = ['Padang', 'Solok', 'Bukittinggi'];
  String? dari;
  String? ke;
  DateTime? tanggal;

  bool showErrorDari = false;
  bool showErrorKe = false;
  bool showErrorTanggal = false;
  bool sameRouteError = false;

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Penumpang'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Pilih Rute Perjalanan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // Dari Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: dari,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Dari',
                          errorText:
                              showErrorDari ? 'Harap lengkapi data ini.' : null,
                        ),
                        items: kota
                            .map((e) => DropdownMenuItem(
                                value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            dari = value;
                            showErrorDari = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Ke Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: ke,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Ke',
                          errorText:
                              showErrorKe ? 'Harap lengkapi data ini.' : null,
                        ),
                        items: kota
                            .map((e) => DropdownMenuItem(
                                value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            ke = value;
                            showErrorKe = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Tombol Tukar
                Container(
                  height: 56,
                  width: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.swap_horiz, color: Colors.white),
                    tooltip: 'Tukar Rute',
                    onPressed: () {
                      setState(() {
                        final temp = dari;
                        dari = ke;
                        ke = temp;
                      });
                    },
                  ),
                ),
              ],
            ),

            if (sameRouteError)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Kota asal dan tujuan tidak boleh sama.',
                  style: TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 16),

            // Tanggal Perjalanan
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Perjalanan',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                    hintText:
                        tanggal != null ? tanggal.toString().split(' ')[0] : 'Pilih tanggal',
                    errorText: showErrorTanggal
                        ? 'Harap lengkapi data ini.'
                        : null,
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        tanggal = picked;
                        showErrorTanggal = false;
                      });
                    }
                  },
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      tanggal = DateTime.now();
                      showErrorTanggal = false;
                    });
                  },
                  child: const Text('Gunakan tanggal hari ini'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tombol Pesan Tiket
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  showErrorDari = dari == null;
                  showErrorKe = ke == null;
                  showErrorTanggal = tanggal == null;
                  sameRouteError = (dari != null && ke != null && dari == ke);
                });

                if (!showErrorDari &&
                    !showErrorKe &&
                    !showErrorTanggal &&
                    !sameRouteError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Pesanan dari $dari ke $ke pada ${tanggal!.toLocal().toString().split(" ")[0]} berhasil!',
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Pesan Tiket'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
