import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiket/register.dart';
import 'package:tiket/user/halaman_utama_user.dart';
import 'package:tiket/petugas/utama_petugas.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  void showForgotDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Lupa Username / Password",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(" ", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tutup", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Future<void> loginUser() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError("username dan password wajib diisi.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        // Uri.parse('http://fifafel.my.id/api/login'),
        Uri.parse('https://fifafel.my.id/api/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      final result = jsonDecode(response.body);
      debugPrint('Login Response: $result');

      if (response.statusCode == 200 && result['status'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final role = result['role'];
        final userData = result['data'];

        if (role == 'penumpang') {
          final idPenumpang = userData['id_penumpang'] ?? userData['id'];

          await prefs.setInt('id_penumpang', idPenumpang);
          await prefs.setString('nama_penumpang', userData['nama_penumpang']);
          await prefs.setString('username', userData['username']);
          await prefs.setString('email', userData['email'] ?? '');
          await prefs.setString('no_telepon', userData['no_telepon'] ?? '');
          await prefs.setString('password', password);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HalamanUtamaUser()),
          );
        } else if (role == 'petugas') {
          await prefs.setInt('id_petugas', userData['id_petugas']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HalamanPetugas()),
          );
        } else {
          _showError("Role tidak dikenali.");
        }
      } else {
        _showError(result['message'] ?? "Login gagal.");
      }
    } catch (e) {
      debugPrint("Login Error: $e");
      _showError("Terjadi kesalahan jaringan.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Login Gagal",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tutup", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFF8B0000), Color(0xFFB71C1C)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 36,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selamat Datang',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const CircleAvatar(
                      radius: 70,
                      backgroundImage: AssetImage('images/logo.jpg'),
                    ),
                    const SizedBox(height: 28),

                    // username
                    TextField(
                      controller: _usernameController,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'username',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                        hintText: 'Masukkan username',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: !isPasswordVisible,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                        hintText: 'Masukkan password',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(
                              () => isPasswordVisible = !isPasswordVisible,
                            );
                          },
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: showForgotDialog,
                        child: Text(
                          'Lupa username dan password?',
                          style: GoogleFonts.poppins(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: Colors.red[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    ElevatedButton(
                      onPressed: isLoading ? null : loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 16,
                        ),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        shadowColor: Colors.redAccent.withOpacity(0.3),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'LOGIN',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Tidak punya akun? ",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Daftar",
                            style: GoogleFonts.poppins(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
