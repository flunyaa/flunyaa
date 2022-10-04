import 'package:flunyaa/nyaa/search_url.dart';
import 'package:flunyaa/pages/view.dart';
import 'package:flunyaa/utils/client.dart';
import 'package:flunyaa/utils/enums.dart';
import 'package:flunyaa/utils/parsers/search_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MyaaSearchListWidget extends StatefulWidget {
  final String query;
  final SearchFilter filter;
  final SearchCategory category;
  final int page;
  const MyaaSearchListWidget({
    super.key,
    this.query = '',
    this.filter = SearchFilter.noFilter,
    this.category = SearchCategory.all,
    this.page = 1,
  });

  @override
  State<StatefulWidget> createState() => _MyaaSearchListWidgetState();
}

class _MyaaSearchListWidgetState extends State<MyaaSearchListWidget> {
  // 当前页数
  late SearchURLBuilder url = SearchURLBuilder(
    query: widget.query,
    filter: widget.filter,
    category: widget.category,
    page: widget.page,
  );
  // 列表数据
  final List<SearchResultItem> _list = [];
  // 是否还有
  final bool _hasMore = true;
  // 滚动控制器
  final ScrollController _scrollController = ScrollController();
  // 是否正在加载
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 40) {
        // _nextPage();
        if (kDebugMode) {
          print('滚动到底部');
        }
        if (!_isLoading) {
          _nextPage();
        }
      }
    });
    _getData();
  }

  Future<void> _getData({reset = false}) async {
    if (kDebugMode) {
      print('获取数据');
    }
    try {
      _isLoading = true;
      final res = await NyaaClient.get(url.toUri());
      final result = SearchPageParser.parseSearchResults(res);
      if (reset) {
        _list.clear();
      }
      _list.addAll(result);
    } catch (e) {
      // Snackbar
      if (kDebugMode) {
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('获取数据失败，请检查网络连接'),
        ),
      );
    } finally {
      _isLoading = false;
    }
    setState(() {});
  }

  Future<void> _nextPage() {
    if (_hasMore) {
      url = url.setPage(url.page + 1);
      return _getData();
    }
    return Future.value();
  }

  Future<void> _refresh() {
    url = url.setPage(1);
    if (_list.isNotEmpty) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
    return _getData(reset: true);
  }

  Future<void> _launchUrl(String url) async {
    // if (!Platform.isAndroid && !Platform.isIOS) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('当前平台不支持打开此链接'),
    //     ),
    //   );
    //   return;
    // }
    // final uri = Uri.parse(url);
    await launchUrlString(url);
    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('当前平台不支持打开此链接'),
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _list.isEmpty
            ? const Center(
                child: Text('加载中'),
              )
            : RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _list.length,
                  itemBuilder: (context, index) {
                    List<Widget> children = [
                      ListTile(
                        title: Text(
                          _list[index].title,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              _list[index].category.title,
                              style: TextStyle(
                                color: _list[index].status.color,
                              ),
                            ),
                            Expanded(child: Container()),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _list[index].seeders.toString(),
                                      style:
                                          const TextStyle(color: Colors.green),
                                    ),
                                    const Text(
                                      '↑ ',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _list[index].leechers.toString(),
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                    const Text(
                                      '↓ ',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(_list[index].completed.toString()),
                                    const Text('✓'),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 70,
                              child: Text(
                                _list[index].size,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NyaaViewPage(
                                item: _list[index],
                              ),
                              // settings: RouteSettings(
                              //   name: 'view',
                              //   arguments: _list[index],
                              // ),
                            ),
                          );
                        },
                        onLongPress: () {
                          final item = _list[index];
                          // show context menu list
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                title: Text(item.title),
                                children: [
                                  SimpleDialogOption(
                                    child: Row(
                                      children: const [
                                        Icon(Icons.copy),
                                        Text(' 复制标题'),
                                      ],
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: item.title),
                                      )
                                          .then(
                                            (value) =>
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                              const SnackBar(
                                                content: Text('已复制标题'),
                                              ),
                                            ),
                                          )
                                          .then(
                                            (value) => Navigator.pop(context),
                                          );
                                    },
                                  ),
                                  SimpleDialogOption(
                                    child: Row(
                                      children: const [
                                        Icon(Icons.copy),
                                        Text(' 复制种子链接'),
                                      ],
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                            text:
                                                'https://nyaa.si${item.torrent}'),
                                      )
                                          .then(
                                            (value) =>
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                              const SnackBar(
                                                content: Text('已复制种子链接'),
                                              ),
                                            ),
                                          )
                                          .then(
                                            (value) => Navigator.pop(context),
                                          );
                                    },
                                  ),
                                  SimpleDialogOption(
                                    child: Row(
                                      children: const [
                                        Icon(Icons.copy),
                                        Text(' 复制磁力链接'),
                                      ],
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: item.magnet),
                                      )
                                          .then(
                                            (value) =>
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                              const SnackBar(
                                                content: Text('已复制磁力链接'),
                                              ),
                                            ),
                                          )
                                          .then(
                                            (value) => Navigator.pop(context),
                                          );
                                    },
                                  ),
                                  SimpleDialogOption(
                                    child: Row(
                                      children: const [
                                        Icon(Icons.download),
                                        Text(' 下载种子文件'),
                                      ],
                                    ),
                                    // onPressed: () {
                                    //   Navigator.pop(context);
                                    // },
                                  ),
                                  SimpleDialogOption(
                                    child: Row(
                                      children: const [
                                        Icon(Icons.open_in_new),
                                        Text(' 打开磁力链接'),
                                      ],
                                    ),
                                    onPressed: () async {
                                      _launchUrl(item.magnet);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      // const Divider()
                    ];
                    if (index == _list.length - 1) {
                      children.add(const SizedBox(
                        height: 50,
                        child: Center(
                          child: Text('加载中'),
                        ),
                      ));
                    }
                    return Column(
                      children: children,
                    );
                  },
                ),
              ),
        Positioned(
          bottom: 10,
          right: 10,
          child: FloatingActionButton(
            onPressed: _refresh,
            tooltip: _list.length.toString(),
            child: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }
}
