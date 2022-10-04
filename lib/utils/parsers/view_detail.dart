import 'package:flunyaa/utils/enums.dart';
import 'package:flunyaa/utils/parsers/search_result.dart';
import 'package:html/parser.dart' show parse;

enum ViewFileType {
  file,
  directory,
}

class ViewFileItem {
  final ViewFileType type;
  final String name;
  final List<ViewFileItem> children;
  ViewFileItem({
    required this.type,
    required this.name,
    this.children = const [],
  });
}

class ViewDetail extends SearchResultItem {
  final String submitter;
  final String infomation;
  final String description;
  final ViewFileItem fileList;
  final String infoHash;

  ViewDetail({
    required super.id,
    required super.category,
    required super.title,
    required super.torrent,
    required super.magnet,
    required super.size,
    required super.date,
    required super.seeders,
    required super.leechers,
    required super.completed,
    required super.status,
    required this.submitter,
    required this.infomation,
    required this.description,
    required this.fileList,
    required this.infoHash,
  });

  @override
  String toString() {
    return 'ViewDetail(category: $category, title: $title, torrent: $torrent, magnet: $magnet, size: $size, date: $date, seeders: $seeders, leechers: $leechers, completed: $completed, status: ${status.title}, submitter: $submitter, infomation: $infomation, description: $description, fileList: $fileList)';
  }
}

class ViewDetailParser {
  final String html;
  final regCategory = RegExp(r'^/\?c=(?<main>\d+)_(?<sub>\d+)$');
  final regTorrent = RegExp(r'^/download/(?<id>\d+)\.torrent$');

  ViewDetailParser.fromHTML(this.html);

  static ViewDetail parseViewDetail(String html) {
    final parser = ViewDetailParser.fromHTML(html);
    return parser._parseViewDetail();
  }

  ViewDetail _parseViewDetail() {
    final document = parse(html);
    final elPanels = document.querySelectorAll('div.panel');
    final details =
        elPanels[0].querySelectorAll('div.panel-body > div.row > div.col-md-5');
    // title
    final String title =
        elPanels[0].querySelector('div.panel-heading > h3')?.text.trim() ?? '';
    // category
    final elCategory = details[0].children.last;
    final categoryString = elCategory.attributes['href'] ?? '';
    final categoryMatch = regCategory.firstMatch(categoryString);
    SearchCategory category;
    if (categoryMatch == null) {
      category = SearchCategory.unknown;
    } else {
      final main = int.parse(categoryMatch.namedGroup('main') ?? '0');
      final sub = int.parse(categoryMatch.namedGroup('sub') ?? '0');
      category = SearchCategory.fromCategory(main, sub);
    }
    // date
    final elDate = details[1];
    final timestamp =
        int.tryParse(elDate.attributes['data-timestamp'] ?? '') ?? 0;
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    // submitter
    final elSubmitter = details[2];
    final submitter = elSubmitter.text.trim();
    // seeders
    final elSeeders = details[3];
    final seeders = int.tryParse(elSeeders.text.trim()) ?? 0;
    // infomation
    final elInfomation = details[4];
    final infomation = elInfomation.text.trim();
    // leechers
    final elLeechers = details[5];
    final leechers = int.tryParse(elLeechers.text.trim()) ?? 0;
    // size
    final elSize = details[6];
    final size = elSize.text.trim();
    // completed
    final elCompleted = details[7];
    final completed = int.tryParse(elCompleted.text.trim()) ?? 0;
    // info hash
    final elInfoHash = details[8];
    final infoHash = elInfoHash.text.trim();
    // description
    final elDescription = document.querySelector('#torrent-description');
    final description = elDescription!.innerHtml;
    // torrent
    final elDownload = elPanels[0].querySelector('div.panel-footer.clearfix');
    final torrent = elDownload!.children.first.attributes['href'] ?? '';
    final torrentMatch = regTorrent.firstMatch(torrent);
    final torrentId = torrentMatch?.namedGroup('id') ?? '';
    final id = int.tryParse(torrentId) ?? 0;
    // magnet
    final magnet = elDownload.children.last.attributes['href'] ?? '';
    return ViewDetail(
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
      status: SearchResultItemStatus.other,
      submitter: submitter,
      infomation: infomation,
      description: description,
      fileList: ViewFileItem(type: ViewFileType.file, name: 'name'),
      infoHash: infoHash,
    );
  }
}
