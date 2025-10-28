import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController emailController =
      TextEditingController(); // ✅ emailController ditambahkan
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController konfirmasiPasswordController =
      TextEditingController();

  bool agree = false;
  bool showPassword = false;
  bool loading = false;

  bool get isFormValid {
    return namaController.text.isNotEmpty &&
        teleponController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        konfirmasiPasswordController.text.isNotEmpty &&
        passwordController.text == konfirmasiPasswordController.text &&
        agree;
  }

  Future<void> registerUser() async {
    setState(() {
      loading = true;
    });

    final url = Uri.parse('https://fifafel.my.id/api/penumpang/register');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nama_penumpang': namaController.text,
          'no_telepon': teleponController.text,
          'email': emailController.text, // ✅ email dikirim
          'username': usernameController.text,
          'password': passwordController.text,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['status'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pendaftaran berhasil!')));
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        });
      } else {
        String pesan = 'Gagal daftar.';

        if (data is Map && data.containsKey('errors')) {
          pesan = data['errors'].values.first[0];
        } else if (data is Map && data.containsKey('message')) {
          pesan = data['message'];
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(pesan)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  InputDecoration buildInputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
      hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.grey[100],
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 9, 9, 9),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Daftar Akun',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFB71C1C),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yuk, lengkapi data dirimu untuk daftar.',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Nama Lengkap
            TextField(
              controller: namaController,
              style: const TextStyle(color: Colors.black),
              decoration: buildInputDecoration('Nama Lengkap'),
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // No Telepon
            TextField(
              controller: teleponController,
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.phone,
              decoration: buildInputDecoration('No Telepon'),
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Email
            TextField(
              controller: emailController, // ✅ input email
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.emailAddress,
              decoration: buildInputDecoration('Email'),
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Username
            TextField(
              controller: usernameController,
              style: const TextStyle(color: Colors.black),
              decoration: buildInputDecoration('Username'),
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Password
            TextField(
              controller: passwordController,
              style: const TextStyle(color: Colors.black),
              obscureText: !showPassword,
              decoration: buildInputDecoration(
                'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[700],
                  ),
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                ),
              ),
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Konfirmasi Password
            TextField(
              controller: konfirmasiPasswordController,
              style: const TextStyle(color: Colors.black),
              obscureText: true,
              decoration: buildInputDecoration('Konfirmasi Password'),
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
            ),
            if (passwordController.text.isNotEmpty &&
                konfirmasiPasswordController.text.isNotEmpty &&
                passwordController.text != konfirmasiPasswordController.text)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  'Password dan konfirmasi password tidak sama',
                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),

            // Checkbox
            Row(
              children: [
                Checkbox(
                  value: agree,
                  onChanged: (bool? value) {
                    setState(() {
                      agree = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFF2196F3),
                ),
                Expanded(
                  child: Text(
                    'Saya setuju dengan syarat dan ketentuan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tombol Daftar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFormValid && !loading ? registerUser : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Text(
                        'Daftar',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Teks "Sudah punya akun?"
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                child: Text(
                  'Login',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: const Color(0xFFB71C1C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
