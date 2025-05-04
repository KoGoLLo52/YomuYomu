abstract class AccountViewContract {
  void updateUserInfo(String username, String date);
  void updateActivity({
    required String mostReadGenre,
    required String mostReadAuthor,
    required List<String> favoriteMangas,
    required int finishedCount,
    required int commentsPosted,
  });
}

abstract class AccountPresenterContract {
  void loadUserData();
}
