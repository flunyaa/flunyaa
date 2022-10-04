import 'package:flunyaa/utils/enums.dart';
import 'package:html/parser.dart' show parse;

class SearchResultItem {
  final int id;
  final SearchCategory category;
  final String title;
  final String torrent;
  final String magnet;
  final String size;
  final DateTime date;
  final int seeders;
  final int leechers;
  final int completed;
  final SearchResultItemStatus status;

  const SearchResultItem({
    required this.id,
    required this.category,
    required this.title,
    required this.torrent,
    required this.magnet,
    required this.size,
    required this.date,
    required this.seeders,
    required this.leechers,
    required this.completed,
    required this.status,
  });

  @override
  String toString() {
    return 'SearchResult(category: $category, title: $title, torrent: $torrent, magnet: $magnet, size: $size, date: $date, seeders: $seeders, leechers: $leechers, completed: $completed, status: ${status.title})';
  }
}

class SearchPageParser {
  final String html;
  final regCategory = RegExp(r'^/\?c=(?<main>\d+)_(?<sub>\d+)$');
  final regId = RegExp(r'^/view/(?<id>\d+)$');

  SearchPageParser.fromHTML(this.html);

  static List<SearchResultItem> parseSearchResults(String html) {
    final parser = SearchPageParser.fromHTML(html);
    return parser._parseSearchResults();
  }

  List<SearchResultItem> _parseSearchResults() {
    final document = parse(html);
    final trs = document.querySelectorAll('table.torrent-list > tbody > tr');
    final results = <SearchResultItem>[];
    for (final tr in trs) {
      final status = SearchResultItemStatus.fromClassName(tr.className);

      final tdCategory = tr.children[0].children.first;
      final tdTitle = tr.children[1].children.last;
      final tdTorrent = tr.children[2].children.first;
      final tdMagnet = tr.children[2].children.last;
      final tdSize = tr.children[3];
      final tdDate = tr.children[4];
      final tdSeeders = tr.children[5];
      final tdLeechers = tr.children[6];
      final tdCompleted = tr.children[7];

      final viewString = tdTitle.attributes['href'] ?? '';
      final viewMatch = regId.firstMatch(viewString);
      final viewId = viewMatch?.namedGroup('id') ?? '';
      final id = int.tryParse(viewId) ?? 0;

      final categoryString = tdCategory.attributes['href'] ?? '';
      final categoryMatch = regCategory.firstMatch(categoryString);
      SearchCategory category;
      if (categoryMatch == null) {
        category = SearchCategory.unknown;
      } else {
        final main = int.parse(categoryMatch.namedGroup('main') ?? '0');
        final sub = int.parse(categoryMatch.namedGroup('sub') ?? '0');
        category = SearchCategory.fromCategory(main, sub);
      }
      final title = tdTitle.text;
      final torrent = tdTorrent.attributes['href'] ?? '';
      final magnet = tdMagnet.attributes['href'] ?? '';
      final size = tdSize.text.trim();
      final timestamp =
          int.tryParse(tdDate.attributes['data-timestamp'] ?? '') ?? 0;
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      final seeders = int.tryParse(tdSeeders.text.trim()) ?? 0;
      final leechers = int.tryParse(tdLeechers.text.trim()) ?? 0;
      final completed = int.tryParse(tdCompleted.text.trim()) ?? 0;
      results.add(SearchResultItem(
        id: id,
        category: category,
        title: title,
        torrent: torrent,
        magnet: magnet,
        size: size,
        date: date,
        seeders: seeders,
        leechers: leechers,
        completed: completed,
        status: status,
      ));
    }
    return results;
  }
}
