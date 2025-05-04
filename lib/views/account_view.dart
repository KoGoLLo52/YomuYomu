import 'package:flutter/material.dart';
import 'package:yomuyomu/contracts/account_contract.dart';
import 'package:yomuyomu/presenters/account_presenter.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView>
    implements AccountViewContract {
  late final AccountPresenterContract _presenter;

  String _username = '';
  String _date = '';
  String _genre = '';
  String _author = '';
  List<String> _mangas = [];
  int _finished = 0;
  int _comments = 0;

  @override
  void initState() {
    super.initState();
    _presenter = AccountPresenter(this);
    _presenter.loadUserData();
  }

  @override
  void updateUserInfo(String username, String date) {
    setState(() {
      _username = username;
      _date = date;
    });
  }

  @override
  void updateActivity({
    required String mostReadGenre,
    required String mostReadAuthor,
    required List<String> favoriteMangas,
    required int finishedCount,
    required int commentsPosted,
  }) {
    setState(() {
      _genre = mostReadGenre;
      _author = mostReadAuthor;
      _mangas = favoriteMangas;
      _finished = finishedCount;
      _comments = commentsPosted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Avatar and User Info
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(
                    "assets/avatar.png",
                  ), // placeholder
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(_date),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),

            // Activity Section
            const Text(
              "Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("Most Read Genre: $_genre"),
            Text("Most Read Author: $_author"),
            const SizedBox(height: 12),

            // Favorite Manga Section
            const Text("Favorite Manga:", style: TextStyle(fontSize: 16)),
            _mangas.isEmpty
                ? const Text("No favorite mangas available.")
                : SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        _mangas.map((url) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: Image.asset(
                              url,
                            ), // Assuming URL is a local asset
                          );
                        }).toList(),
                  ),
                ),

            const SizedBox(height: 12),

            // Finished Count and Comments
            Text("Finished Mangas Count: $_finished"),
            Text("Comments Posted: $_comments"),
          ],
        ),
      ),
    );
  }
}
