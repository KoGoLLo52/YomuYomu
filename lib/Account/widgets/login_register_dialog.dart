import 'package:flutter/material.dart';
import 'package:yomuyomu/Account/widgets/forms/login_form.dart';
import 'package:yomuyomu/Account/widgets/forms/register_form.dart';

class LoginRegisterDialog extends StatelessWidget {
  final VoidCallback loadUserData;
  final Future<void> Function(String username, String email) saveUserToDatabase;

  const LoginRegisterDialog({
    super.key,
    required this.loadUserData,
    required this.saveUserToDatabase,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: DefaultTabController(
        length: 2,
        child: SizedBox(
          width: MediaQuery.of(context).size.width > 600 ? 600 : double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const TabBar(
                indicatorColor: Colors.cyan,
                labelColor: Colors.cyan,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Iniciar sesión'),
                  Tab(text: 'Registrarse'),
                ],
              ),
              SizedBox(
                height: 400,
                child: TabBarView(
                  children: [
                    LoginForm(onLoginSuccess: loadUserData),
                    RegisterForm(
                      onRegisterSuccess: loadUserData,
                      saveUserToDatabase: saveUserToDatabase,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
