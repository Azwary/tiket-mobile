import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'jadwal_user.dart';
import 'profile.dart';
import 'tiket.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  Intl.defaultLocale = 'id';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', ''), Locale('en', '')],
      locale: const Locale('id'),
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF960000),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HalamanUtamaUser(),
    );
  }
}

class HalamanUtamaUser extends StatefulWidget {
  const HalamanUtamaUser({super.key});

  static final globalKey = GlobalKey<_HalamanUtamaUserState>();

  @override
  State<HalamanUtamaUser> createState() => _HalamanUtamaUserState();
}

class _HalamanUtamaUserState extends State<HalamanUtamaUser> {
  int currentIndex = 0;
  int? idPenumpang;

  void setTabIndex(int index) {
    setState(() => currentIndex = index);
  }

  String? dari;
  String? ke;
  DateTime? tanggal;
  final tanggalController = TextEditingController();
  final TextEditingController dariController = TextEditingController();
  final TextEditingController keController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final Color merahUtama = const Color(0xFF960000);

  List<String> daftarKotaAsal = [];
  List<String> daftarKotaTujuan = [];
  List<Map<String, dynamic>> daftarRute = [];

  @override
  void initState() {
    super.initState();
    getIdPenumpang();
    fetchRute();
  }

  @override
  void dispose() {
    tanggalController.dispose();
    dariController.dispose();
    keController.dispose();
    super.dispose();
  }

  Future<void> getIdPenumpang() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      idPenumpang = prefs.getInt('id_penumpang');
    });
  }

  Future<void> fetchRute() async {
    try {
      final response = await http.get(
        Uri.parse('https://fifafel.my.id/api/rute'),
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('data')) {
          setState(() {
            daftarRute = List<Map<String, dynamic>>.from(data['data']);
            daftarKotaAsal =
                daftarRute.map((e) => e['asal'].toString()).toSet().toList()
                  ..sort();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("API error: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal ambil data rute: $e")));
      }
    }
  }

  void updateKotaTujuan(String asal) {
    final tujuanSet =
        daftarRute
            .where((r) => r['asal'] == asal)
            .map((r) => r['tujuan'].toString())
            .toSet()
            .toList()
          ..sort();
    setState(() {
      daftarKotaTujuan = tujuanSet;
    });
  }

  void _setTanggal(DateTime date) {
    setState(() {
      tanggal = date;
      tanggalController.text = DateFormat('dd MMMM yyyy', 'id').format(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody;

    // Jika idPenumpang belum siap, tampilkan CircularProgressIndicator
    if (idPenumpang == null) {
      currentBody = const Center(child: CircularProgressIndicator());
    } else {
      if (currentIndex == 0) {
        currentBody = _buildBeranda(context);
      } else if (currentIndex == 1) {
        currentBody = TiketSayaPage(idPenumpang: idPenumpang!);
      } else {
        currentBody = ProfilePage(userId: idPenumpang!);
      }
    }

    return Scaffold(
      body: currentBody,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: merahUtama,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Tiket Saya',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildBeranda(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 220,
              viewportFraction: 1,
              autoPlay: true,
            ),
            items: ['images/fotoo1.jpg', 'images/fotoo2.png'].map((i) {
              return Image.asset(i, fit: BoxFit.cover, width: double.infinity);
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildFormRute(context),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: ElevatedButton.icon(
              onPressed: _onPesanPressed,
              icon: const Icon(Icons.search, color: Colors.white),
              label: Text(
                "Pesan Tiket",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: merahUtama,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildSectionCard("Fasilitas Bus", [
            _buildFasilitasCard(Icons.gavel, "Palu Darurat", Colors.red),
            _buildFasilitasCard(
              Icons.fire_extinguisher,
              "Alat Pemadam Api",
              Colors.orange,
            ),
            _buildFasilitasCard(
              Icons.battery_charging_full,
              "Port Pengisian Daya",
              Colors.blue,
            ),
            _buildFasilitasCard(
              Icons.surround_sound,
              "Sistem Audio",
              Colors.purple,
            ),
            _buildFasilitasCard(Icons.event_seat, "Kursi Nyaman", Colors.teal),
            _buildFasilitasCard(Icons.mic, "Mikrofon Karaoke", Colors.pink),
            _buildFasilitasCard(
              Icons.ac_unit,
              "Pendingin Udara (AC)",
              Colors.lightBlue,
            ),
            _buildFasilitasCard(Icons.tv, "Televisi Hiburan", Colors.green),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFormRute(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // 🔹 Autocomplete "Dari"
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return daftarKotaAsal;
              }
              return daftarKotaAsal.where(
                (kota) => kota.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
                  dariController.text = controller.text;

                  focusNode.addListener(() {
                    if (focusNode.hasFocus) {
                      setState(() {});
                    }
                  });

                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Dari",
                      prefixIcon: Icon(Icons.my_location),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Masukkan kota asal" : null,
                    onChanged: (v) {
                      dari = v;
                      updateKotaTujuan(v);
                    },
                  );
                },
            onSelected: (String selection) {
              dari = selection;
              updateKotaTujuan(selection);
            },
          ),
          const SizedBox(height: 12),

          // 🔹 Autocomplete "Ke"
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return daftarKotaTujuan;
              }
              return daftarKotaTujuan.where(
                (kota) => kota.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
                  keController.text = controller.text;

                  focusNode.addListener(() {
                    if (focusNode.hasFocus) {
                      setState(() {});
                    }
                  });

                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Ke",
                      prefixIcon: Icon(Icons.flag),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Masukkan kota tujuan" : null,
                    onChanged: (v) => ke = v,
                  );
                },
            onSelected: (String selection) {
              ke = selection;
            },
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: tanggalController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Tanggal Perjalanan",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      locale: const Locale('id'),
                    );
                    if (picked != null) _setTanggal(picked);
                  },
                  validator: (v) => v == null || v.isEmpty
                      ? "Pilih tanggal perjalanan"
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _setTanggal(DateTime.now()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: merahUtama,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Hari Ini",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFasilitasCard(IconData icon, String text, Color color) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPesanPressed() {
    if (formKey.currentState!.validate()) {
      if (dari == ke) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kota asal dan tujuan tidak boleh sama"),
          ),
        );
        return;
      }

      final rute = daftarRute.firstWhere(
        (r) =>
            r['asal'].toString().toLowerCase() == dari!.toLowerCase() &&
            r['tujuan'].toString().toLowerCase() == ke!.toLowerCase(),
        orElse: () => <String, dynamic>{},
      );

      if (rute.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Rute tidak ditemukan")));
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HalamanJadwalUser(
            userId: idPenumpang!,
            idRute: rute['id_rute'],
            dari: dari!,
            ke: ke!,
            tanggal: tanggalController.text,
            harga: rute['harga'],
          ),
        ),
      );
    }
  }
}
