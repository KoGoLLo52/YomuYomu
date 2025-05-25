import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yomuyomu/contracts/account_contract.dart';
import 'package:yomuyomu/models/account_model.dart';
import 'package:yomuyomu/presenters/account_presenter.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView>
    implements AccountViewContract {
  late final AccountPresenterContract _presenter;
  late final StreamSubscription<User?> _authSubscription;

  AccountModel? _account;

  @override
  void initState() {
    super.initState();
    _presenter = AccountPresenter(this);

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _presenter.loadUserData();
      } else {
        setState(() {
          _account = null;
        });
      }
    });
  }

  @override
  void updateAccount(AccountModel account) {
    if (!mounted) return;
    setState(() {
      _account = account;
    });
  }

  void _showAccountOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
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
                  _showLoginRegisterDialog();
                },
              ),
              if (_account != null)
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Cerrar sesión"),
                  onTap: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sesión cerrada')),
                    );
                    _presenter.loadUserData();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showLoginRegisterDialog() {
    final loginFormKey = GlobalKey<FormState>();
    final registerFormKey = GlobalKey<FormState>();

    final loginEmailController = TextEditingController();
    final loginPasswordController = TextEditingController();

    final registerEmailController = TextEditingController();
    final registerPasswordController = TextEditingController();
    final registerUsernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: DefaultTabController(
            length: 2,
            child: SizedBox(
              width:
                  MediaQuery.of(context).size.width > 600
                      ? 600
                      : double.infinity,
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
                        // Login Form
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: loginFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: loginEmailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? 'Ingrese su email'
                                              : null,
                                ),
                                TextFormField(
                                  controller: loginPasswordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Contraseña',
                                  ),
                                  obscureText: true,
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? 'Ingrese su contraseña'
                                              : null,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.login),
                                  label: const Text("Iniciar sesión"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyan,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    if (!loginFormKey.currentState!.validate()) {
                                      return;
                                    }

                                    final email =
                                        loginEmailController.text.trim();
                                    final password =
                                        loginPasswordController.text.trim();

                                    try {
                                      await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                            email: email,
                                            password: password,
                                          );
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Sesión iniciada'),
                                        ),
                                      );
                                      _presenter.loadUserData();
                                    } catch (e) {
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder:
                                            (_) => AlertDialog(
                                              title: const Text('Error'),
                                              content: Text(
                                                'No se pudo iniciar sesión:\n$e',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Register Form
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: registerFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: registerUsernameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre de usuario',
                                  ),
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? 'Ingrese un nombre de usuario'
                                              : null,
                                ),
                                TextFormField(
                                  controller: registerEmailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? 'Ingrese su email'
                                              : null,
                                ),
                                TextFormField(
                                  controller: registerPasswordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Contraseña',
                                  ),
                                  obscureText: true,
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? 'Ingrese su contraseña'
                                              : null,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.person_add),
                                  label: const Text("Registrarse"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    if (!registerFormKey.currentState!
                                        .validate()) {
                                      return;
                                    }

                                    final username =
                                        registerUsernameController.text.trim();
                                    final email =
                                        registerEmailController.text.trim();
                                    final password =
                                        registerPasswordController.text.trim();

                                    try {
                                      final cred = await FirebaseAuth.instance
                                          .createUserWithEmailAndPassword(
                                            email: email,
                                            password: password,
                                          );
                                      await cred.user?.updateDisplayName(
                                        username,
                                      );
                                      await _presenter.saveUserToDatabase(
                                        username,
                                        email,
                                      );

                                      if (!mounted) return;
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Cuenta creada exitosamente',
                                          ),
                                        ),
                                      );
                                      _presenter.loadUserData();
                                    } catch (e) {
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder:
                                            (_) => AlertDialog(
                                              title: const Text('Error'),
                                              content: Text(
                                                'No se pudo registrar:\n$e',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = _account;

    ImageProvider avatarImage;
    if (account != null && account.icon != null && account.icon!.isNotEmpty) {
      avatarImage = NetworkImage(account.icon!);
    } else {
      avatarImage = const AssetImage("assets/avatar.png");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cuenta"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showAccountOptions,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              children: [
                CircleAvatar(radius: 40, backgroundImage: avatarImage),
                const SizedBox(width: 16),
                Expanded(
                  child:
                      account != null
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.username,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await FirebaseAuth.instance.signOut();
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Sesión cerrada'),
                                    ),
                                  );
                                  _presenter.loadUserData();
                                },
                                child: Text(
                                  account.email,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : GestureDetector(
                            onTap: _showLoginRegisterDialog,
                            child: const Text(
                              'Iniciar sesión / Registrarse',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text(
              "Actividad",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("Género más leído: ${account?.mostReadGenre ?? ''}"),
            Text("Autor más leído: ${account?.mostReadAuthor ?? ''}"),
            const SizedBox(height: 12),
            const Text("Favoritos:", style: TextStyle(fontSize: 16)),
            account == null || account.favoriteMangaCovers.isEmpty
                ? const Text("No tienes mangas favoritos.")
                : SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        account.favoriteMangaCovers
                            .map(
                              (uri) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: Image.network(uri.toString()),
                              ),
                            )
                            .toList(),
                  ),
                ),
            const SizedBox(height: 12),
            Text("Mangas terminados: ${account?.finishedMangasCount ?? 0}"),
            Text("Comentarios publicados: ${account?.commentsPosted ?? 0}"),
          ],
        ),
      ),
    );
  }

  @override
  void hideLoading() {}

  @override
  void showError(String message) {}

  @override
  void showLoading() {}

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
