class AccountModel {
  final String username;
  final String dateOfCreation;
  final String mostReadGenre;
  final String mostReadAuthor;
  final List<String> favoriteMangaUrls;
  final int finishedMangasCount;
  final int commentsPosted;

  AccountModel({
    required this.username,
    required this.dateOfCreation,
    required this.mostReadGenre,
    required this.mostReadAuthor,
    required this.favoriteMangaUrls,
    required this.finishedMangasCount,
    required this.commentsPosted,
  });
}
