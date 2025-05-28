import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yomuyomu/Account/contracts/account_contract.dart';
import 'package:yomuyomu/Account/model/account_model.dart';
import 'package:yomuyomu/Account/presenter/account_presenter.dart';
import 'package:yomuyomu/Account/widgets/login_register_dialog.dart';
import 'package:yomuyomu/Account/widgets/user_avatar.dart';

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
      if (!mounted) return;

      if (user != null) {
        _presenter.loadUserData();
      } 
    });
  }

  @override
  void updateAccount(AccountModel? account) {
    if (!mounted) return;
    setState(() => _account = account);
  }

  void _showLoginRegisterDialog() {
    showDialog(
      context: context,
      builder:
          (_) => LoginRegisterDialog(
            loadUserData: _presenter.loadUserData,
            saveUserToDatabase: _presenter.saveUserToDatabase,
          ),
    );
  }

  Future<void> _handleLogout() async {
    await _presenter.logout();
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            UserAvatarWidget(
              account: _account,
              onLogout: _handleLogout,
              onLoginRegister: _showLoginRegisterDialog,
            ),
            const Divider(height: 32),
            const Text(
              "Actividad",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text("Favoritos:", style: TextStyle(fontSize: 16)),
            _account == null || _account!.favoriteMangaCovers.isEmpty
                ? const Text("No tienes mangas favoritos.")
                : SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        _account!.favoriteMangaCovers.map((path) {
                          final isLocal =
                              path.startsWith('file:/') ||
                              path.contains(
                                r':\',
                              ); 

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  isLocal
                                      ? Image.file(
                                        File(path),
                                        width: 100,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.network(
                                        path,
                                        width: 100,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
            const SizedBox(height: 12),
            Text("Mangas terminados: ${_account?.finishedMangasCount ?? 0}"),
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
