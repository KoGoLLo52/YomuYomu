import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yomuyomu/Account/helpers/user_session_helper.dart';
import 'package:yomuyomu/DataBase/database_helper.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onRegisterSuccess;
  final Future<void> Function(String username, String email) saveUserToDatabase;

  const RegisterForm({
    super.key,
    required this.onRegisterSuccess,
    required this.saveUserToDatabase,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = cred.user;
      if (firebaseUser == null)
        throw Exception('No se pudo obtener el usuario de Firebase.');

      await firebaseUser.updateDisplayName(username);
      await widget.saveUserToDatabase(username, email);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada exitosamente')),
      );

      final oldLocalId = await UserSession.getStoredUserId();
      final newFirebaseId = firebaseUser.uid;

      if (oldLocalId != newFirebaseId) {
        await DatabaseHelper.instance.migrateUserData(
          oldLocalId,
          newFirebaseId,
        );
        await UserSession.clear();
      }

      widget.onRegisterSuccess();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorDialog('No se pudo registrar:\n$e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Nombre de usuario'),
              validator:
                  (value) =>
                      value!.isEmpty ? 'Ingrese un nombre de usuario' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value!.isEmpty ? 'Ingrese su email' : null,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
              validator:
                  (value) => value!.isEmpty ? 'Ingrese su contraseña' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text("Registrarse"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: _handleRegister,
            ),
          ],
        ),
      ),
    );
  }
}
