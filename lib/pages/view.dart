import 'package:flunyaa/utils/client.dart';
import 'package:flunyaa/utils/parsers/search_result.dart';
import 'package:flunyaa/utils/parsers/view_detail.dart';
import 'package:flunyaa/widgets/proxied_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:markdown/markdown.dart' show markdownToHtml, ExtensionSet;
import 'package:url_launcher/url_launcher_string.dart';

class NyaaViewPage extends StatefulWidget {
  final SearchResultItem item;
  const NyaaViewPage({super.key, required this.item});

  @override
  State<NyaaViewPage> createState() => _NyaaViewPageState();
}

class _NyaaViewPageState extends State<NyaaViewPage> {
  late ViewDetail detail = ViewDetail(
    id: 0,
    category: widget.item.category,
    title: widget.item.title,
    torrent: widget.item.torrent,
    magnet: widget.item.magnet,
    size: widget.item.size,
    date: widget.item.date,
    seeders: widget.item.seeders,
    leechers: widget.item.leechers,
    completed: widget.item.completed,
    status: widget.item.status,
    submitter: '',
    infomation: '',
    description: '',
    fileList: ViewFileItem(
      type: ViewFileType.directory,
      name: 'root',
      children: [],
    ),
    infoHash: '',
  );
  late final viewUrl = Uri.parse('https://nyaa.si/view/${widget.item.id}');

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (kDebugMode) {
      print(viewUrl);
    }
    final html = await NyaaClient.get(viewUrl);
    final detail = ViewDetailParser.parseViewDetail(html);
    this.detail = detail;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mdString = HtmlUnescape().convert(detail.description);
    // 对 Markdown 字符串进行修复
    // TODO: 部分 Markdown 语法无法正确解析，例如：部分表头下的列数指示行的列数存在问题，需要通过解析删除。
    final fixedMdString = mdString.replaceAll(RegExp(r'(?<!\|)\n\|'), '\n\n|');
    if (kDebugMode) {
      print(fixedMdString);
      // Clipboard.setData(ClipboardData(text: fixedMdString));
    }
    final html = markdownToHtml(fixedMdString,
        extensionSet: ExtensionSet.gitHubFlavored);
    if (kDebugMode) {
      print(html);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(detail.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: '外部打开',
            onPressed: () {
              launchUrlString(viewUrl.toString(),
                  mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(60),
                1: FlexColumnWidth(),
              },
              children: [
                TableRow(
                  children: [
                    const Text('标题'),
                    Text(detail.title),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('类型'),
                    Text(detail.category.title),
                  ],
                ),
                const TableRow(
                  children: [
                    Text('发布者'),
                    // TODO: 未实现，发布者显示
                    Text('-'),
                  ],
                ),
                const TableRow(
                  children: [
                    Text('信息'),
                    // TODO: 信息显示，种子附加信息
                    Text('-'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('大小'),
                    Text(detail.size),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('日期'),
                    Text(detail.date.toLocal().toString()),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('状态'),
                    Text(detail.status.title),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('上传'),
                    Text(detail.seeders.toString()),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('下载'),
                    Text(detail.leechers.toString()),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('完成'),
                    Text(detail.completed.toString()),
                  ],
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: 'https://nyaa.si${detail.torrent}'),
                      )
                          .then(
                            (value) =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('已复制种子链接'),
                              ),
                            ),
                          )
                          .then(
                            (value) => Navigator.pop(context),
                          );
                    },
                    child: const Text('复制种子链接'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: detail.magnet),
                      )
                          .then(
                            (value) =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('已复制磁力链接'),
                              ),
                            ),
                          )
                          .then(
                            (value) => Navigator.pop(context),
                          );
                    },
                    child: const Text('复制磁力链接'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      launchUrlString('https://nyaa.si${detail.torrent}',
                          mode: LaunchMode.externalApplication);
                    },
                    child: const Text('下载这个种子'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      launchUrlString(detail.magnet,
                          mode: LaunchMode.platformDefault);
                    },
                    child: const Text('打开磁力链接'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('描述'),
                // TODO: 还未对链接的点击进行处理
                Html(
                  data: html,
                  onImageError: (exception, stackTrace) {
                    if (kDebugMode) {
                      print(exception);
                    }
                  },
                  customImageRenders: {
                    networkSourceMatcher(): (context, attributes, element) {
                      final String src = attributes['src'] ?? 'about:blank';
                      return ProxiedImageWidget(url: src);
                    },
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
