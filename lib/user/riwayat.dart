import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_riwayat.dart';

class RiwayatPage extends StatefulWidget {
  final int idPenumpang;

  const RiwayatPage({super.key, required this.idPenumpang});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<Map<String, dynamic>> riwayat = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    try {
      final response = await http.get(
        Uri.parse('https://fifafel.my.id/api/tiket/${widget.idPenumpang}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true) {
          final List tiketList = jsonResponse['data'];

          setState(() {
            riwayat = tiketList.map((e) => e as Map<String, dynamic>).toList();
            _updateStatus();
            // urutkan berdasarkan tanggal pemesanan terbaru
            riwayat.sort(
              (a, b) =>
                  b['tanggal_pemesanan'].compareTo(a['tanggal_pemesanan']),
            );
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          print('Gagal mengambil data tiket: ${jsonResponse['message']}');
        }
      } else {
        print('Failed to load data, status code: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  void _updateStatus() {
    final now = DateTime.now();

    for (var tiket in riwayat) {
      final status = (tiket['status'] ?? '').toString().toLowerCase();

      try {
        final tgl = DateTime.parse(tiket['tanggal_keberangkatan']);
        final jamList = tiket['jam'].split(':');
        final waktuTiket = DateTime(
          tgl.year,
          tgl.month,
          tgl.day,
          int.parse(jamList[0]),
          int.parse(jamList[1]),
        ).add(const Duration(minutes: 00)); // +1 menit buffer

        if (status != 'ditolak' && waktuTiket.isBefore(now)) {
          tiket['status'] = 'Selesai';
        }
      } catch (_) {
        // Abaikan jika format tanggal/jam salah
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Hanya tiket Selesai atau Ditolak dan sudah lewat waktunya +1 menit
    final tiketTampil = riwayat.where((t) {
      final status = (t['status'] ?? '').toString().toLowerCase();
      try {
        final tgl = DateTime.parse(t['tanggal_keberangkatan']);
        final jamList = t['jam'].split(':');
        final waktuTiket = DateTime(
          tgl.year,
          tgl.month,
          tgl.day,
          int.parse(jamList[0]),
          int.parse(jamList[1]),
        ).add(const Duration(minutes: 1));

        return (status == 'selesai' || status == 'ditolak') &&
            waktuTiket.isBefore(now);
      } catch (_) {
        return false;
      }
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Riwayat Pemesanan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color.fromARGB(255, 150, 0, 0),
        elevation: 0,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : tiketTampil.isEmpty
            ? Center(
                child: Text(
                  'Belum ada riwayat pemesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tiketTampil.length,
                itemBuilder: (context, i) {
                  final ticket = tiketTampil[i];
                  final status = (ticket['status'] ?? '')
                      .toString()
                      .toLowerCase();

                  Color statusColor;
                  if (status == 'selesai' || status == 'aktif') {
                    statusColor = Colors.green;
                  } else if (status == 'ditolak') {
                    statusColor = Colors.red;
                  } else {
                    statusColor = Colors.grey;
                  }

                  return GestureDetector(
                    onTap: () {
                      _updateStatus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailRiwayatPage(data: ticket),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Tanggal Pemesanan
                          Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 240, 240, 240),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tanggal Pemesanan: ${ticket['tanggal_pemesanan']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    color: const Color.fromARGB(255, 80, 0, 0),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Rute & Detail
                          Container(
                            margin: const EdgeInsets.only(
                              left: 12,
                              right: 12,
                              bottom: 14,
                            ),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Icon bus
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.directions_bus_rounded,
                                    size: 22,
                                    color: Color.fromARGB(255, 150, 0, 0),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Info utama
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${ticket['asal']} → ${ticket['tujuan']}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${ticket['tanggal_keberangkatan']} • ${ticket['jam']}',
                                        style: GoogleFonts.inter(
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Nomor: ${ticket['nomor_tiket']}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.people_alt_rounded,
                                            size: 16,
                                            color: Colors.black54,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${(ticket['penumpang'] as List).length} Penumpang',
                                            style: GoogleFonts.inter(
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Status & total bayar
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        ticket['status'],
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _formatRupiah(ticket['total_bayar']),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatRupiah(dynamic value) {
    final n = (value is num)
        ? value.toInt()
        : int.tryParse(value.toString().split('.').first) ?? 0;
    final s = n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $s';
  }
}
