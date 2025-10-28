import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'halaman_konfirmasi_pembayaran.dart';
import 'package:intl/date_symbol_data_local.dart';

class HalamanPembayaranUser extends StatefulWidget {
  final String dari;
  final String ke;
  final String tanggal;
  final String jamKeberangkatan;
  final List<int> kursi;
  final int harga;
  final String? namaPenumpang;
  final int idPenumpang;
  final int idJadwal;
  final int idPemesanan;

  const HalamanPembayaranUser({
    super.key,
    required this.dari,
    required this.ke,
    required this.tanggal,
    required this.jamKeberangkatan,
    required this.kursi,
    required this.harga,
    required this.namaPenumpang,
    required this.idPenumpang,
    required this.idJadwal,
    required this.idPemesanan,
  });

  @override
  State<HalamanPembayaranUser> createState() => _HalamanPembayaranUserState();
}

class _HalamanPembayaranUserState extends State<HalamanPembayaranUser> {
  final formatter = NumberFormat.decimalPattern();
  final List<TextEditingController> namaControllers = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id', null); // inisialisasi locale Indonesia

    for (int i = 0; i < widget.kursi.length; i++) {
      final controller = TextEditingController();

      // Penumpang pertama otomatis terisi dari login
      if (i == 0 && widget.namaPenumpang != null) {
        controller.text = widget.namaPenumpang!;
      }

      namaControllers.add(controller);
    }
  }

  @override
  void dispose() {
    for (var c in namaControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalBayar = widget.kursi.length * widget.harga;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Penumpang"),
        backgroundColor: const Color.fromARGB(255, 150, 0, 0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CARD INFORMASI PEMESANAN ---
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Informasi Pemesanan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _infoRow("Rute", "${widget.dari} → ${widget.ke}"),
                    _infoRow("Tanggal", widget.tanggal),
                    _infoRow("Jam", widget.jamKeberangkatan),
                    const Divider(height: 24),
                    Text(
                      "Total Pembayaran: Rp ${formatter.format(totalBayar)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- DETAIL PENUMPANG ---
            const Text(
              "Detail Penumpang",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.kursi.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Penumpang ${index + 1}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Kursi ${widget.kursi[index]}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: namaControllers[index],
                          decoration: InputDecoration(
                            hintText: "Nama Penumpang",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.black54,
                                width: 1.2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 88),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 150, 0, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              List<String> namaPenumpangList = namaControllers
                  .map((c) => c.text.trim())
                  .toList();

              if (namaPenumpangList.any((nama) => nama.isEmpty)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Harap isi semua nama penumpang"),
                  ),
                );
                return;
              }

              final List<Map<String, dynamic>> detailPenumpang = List.generate(
                widget.kursi.length,
                (i) => {
                  "id_jadwal": widget.idJadwal, // 🔥 Tambahkan ini
                  "id_kursi": widget.kursi[i], // ubah key jadi id_kursi
                  "nama": namaPenumpangList[i],
                },
              );

              // Pastikan tanggal diformat ke yyyy-MM-dd
              final parsedTanggal = DateFormat(
                'dd MMMM yyyy',
                'id',
              ).parse(widget.tanggal);
              final formattedTanggal = DateFormat(
                'yyyy-MM-dd',
              ).format(parsedTanggal);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HalamanKonfirmasiPembayaran(
                    dari: widget.dari,
                    ke: widget.ke,
                    tanggal: formattedTanggal, // ✅ sudah format aman
                    jamKeberangkatan: widget.jamKeberangkatan,
                    totalBayar: totalBayar,
                    detailPenumpang: detailPenumpang,
                    idPemesanan: widget.idPemesanan,
                  ),
                ),
              );
            },
            child: const Text(
              "Lanjut ke Pembayaran",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
