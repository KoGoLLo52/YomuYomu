import 'package:flutter/material.dart';

class AccountOptionsDialog extends StatelessWidget {
  final VoidCallback onLoginRegister;
  final VoidCallback? onLogout;

  const AccountOptionsDialog({
    required this.onLoginRegister,
    this.onLogout,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Opciones de cuenta",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text("Iniciar sesión / Registrarse"),
            onTap: () {
              Navigator.pop(context);
              onLoginRegister();
            },
          ),
          if (onLogout != null)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Cerrar sesión"),
              onTap: () {
                Navigator.pop(context);
                onLogout!();
              },
            ),
        ],
      ),
    );
  }
}
