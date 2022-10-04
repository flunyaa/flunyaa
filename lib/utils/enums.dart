import 'package:flutter/material.dart';

enum SearchFilter {
  noFilter(title: 'No filter', value: 0),
  noRemakes(title: 'No remakes', value: 1),
  trustedOnly(title: 'Trusted only', value: 2);

  const SearchFilter({
    required this.title,
    required this.value,
  });

  final String title;
  final int value;
}

enum SearchCategory {
  all(title: 'All categories', mainCategory: 0, subCategory: 0),
  anime(title: 'Anime', mainCategory: 1, subCategory: 0),
  animeAMV(title: 'Anime - AMV', mainCategory: 1, subCategory: 1),
  animeEnglish(title: 'Anime - English', mainCategory: 1, subCategory: 2),
  animeNonEnglish(
      title: 'Anime - Non-English', mainCategory: 1, subCategory: 3),
  animeRaw(title: 'Anime - Raw', mainCategory: 1, subCategory: 4),
  audio(title: 'Audio', mainCategory: 2, subCategory: 0),
  audioLossless(
    title: 'Audio - Lossless',
    mainCategory: 2,
    subCategory: 1,
    color: Colors.yellow,
  ),
  audioLossy(title: 'Audio - Lossy', mainCategory: 2, subCategory: 2),
  literature(title: 'Literature', mainCategory: 3, subCategory: 0),
  literatureEnglish(
      title: 'Literature - English', mainCategory: 3, subCategory: 1),
  literatureNonEnglish(
      title: 'Literature - Non-English', mainCategory: 3, subCategory: 2),
  literatureRaw(title: 'Literature - Raw', mainCategory: 3, subCategory: 3),
  liveAction(title: 'Live Action', mainCategory: 4, subCategory: 0),
  liveActionEnglish(
      title: 'Live Action - English', mainCategory: 4, subCategory: 1),
  liveActionIdolPV(
      title: 'Live Action - Idol/PV', mainCategory: 4, subCategory: 2),
  liveActionNonEnglish(
      title: 'Live Action - Non-English', mainCategory: 4, subCategory: 3),
  liveActionRaw(title: 'Live Action - Raw', mainCategory: 4, subCategory: 4),
  pictures(title: 'Pictures', mainCategory: 5, subCategory: 0),
  picturesGraphics(
      title: 'Pictures - Graphics', mainCategory: 5, subCategory: 1),
  picturesPhotos(title: 'Pictures - Photos', mainCategory: 5, subCategory: 2),
  software(title: 'Software', mainCategory: 6, subCategory: 0),
  softwareApps(title: 'Software - Apps', mainCategory: 6, subCategory: 1),
  softwareGames(title: 'Software - Games', mainCategory: 6, subCategory: 2),
  unknown(title: 'Unknown', mainCategory: -1, subCategory: -1);

  const SearchCategory({
    required this.title,
    required this.mainCategory,
    required this.subCategory,
    this.color = Colors.transparent,
  });

  final String title;
  final int mainCategory;
  final int subCategory;
  final Color color;

  String get category => '${mainCategory}_$subCategory';

  static SearchCategory fromTitle(String category) {
    const categories = SearchCategory.values;
    for (final c in categories) {
      if (c.title == category) {
        return c;
      }
    }
    return SearchCategory.unknown;
  }

  static SearchCategory fromCategory(int mainCategory, int subCategory) {
    const categories = SearchCategory.values;
    for (final c in categories) {
      if (c.mainCategory == mainCategory && c.subCategory == subCategory) {
        return c;
      }
    }
    return SearchCategory.unknown;
  }
}

enum SearchResultItemStatus {
  remake(title: 'Remake', className: 'danger', color: Colors.red),
  trusted(title: 'Trusted', className: 'success', color: Colors.green),
  other(title: 'Default', className: 'default', color: Colors.grey);

  const SearchResultItemStatus({
    required this.title,
    required this.className,
    required this.color,
  });

  final String title;
  final String className;
  final Color color;

  static SearchResultItemStatus fromClassName(String className) {
    switch (className) {
      case 'danger':
        return SearchResultItemStatus.remake;
      case 'success':
        return SearchResultItemStatus.trusted;
      default:
        return SearchResultItemStatus.other;
    }
  }
}
