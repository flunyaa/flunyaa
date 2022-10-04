import 'package:flunyaa/nyaa/search_url.dart';
import 'package:flunyaa/utils/client.dart';
import 'package:flunyaa/utils/enums.dart';
import 'package:flunyaa/utils/parsers/search_result.dart';
import 'package:flunyaa/utils/parsers/view_detail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DevelopmentPage extends StatefulWidget {
  const DevelopmentPage({super.key});

  @override
  State<DevelopmentPage> createState() => _DevelopmentPageState();
}

class _DevelopmentPageState extends State<DevelopmentPage> {
  final _formKey = GlobalKey<FormState>();
  final query = TextEditingController();
  SearchFilter filter = SearchFilter.noFilter;
  SearchCategory category = SearchCategory.all;
  int page = 1;
  String urlString = SearchURLBuilder().toString();
  // View
  final viewUrl = TextEditingController(text: 'https://nyaa.si/view/1585623');

  void update() {
    final v = query.value.text;
    urlString = SearchURLBuilder.query(v)
        .setPage(page)
        .setFilter(filter)
        .setCategory(category)
        .toString();
    setState(() {});
  }

  void addPage(int p) {
    if (page + p > 0) {
      page += p;
      update();
    }
  }

  Future<void> sendRequest() async {
    final url = SearchURLBuilder.query(query.value.text)
        .setPage(page)
        .setFilter(filter)
        .setCategory(category)
        .toUri();
    final html = await NyaaClient.get(url);
    final result = SearchPageParser.parseSearchResults(html);
    // for (final r in result) {
    if (kDebugMode) {
      print(result[0]);
    }
    // }
  }

  Future<void> sendDetailRequest() async {
    final res = await NyaaClient.get(Uri.parse(viewUrl.text));
    final result = ViewDetailParser.parseViewDetail(res);
    if (kDebugMode) {
      print(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Development'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '加载列表',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: query,
                    decoration: const InputDecoration(
                      hintText: '搜索内容',
                    ),
                    onEditingComplete: () {
                      _formKey.currentState?.save();
                    },
                    onSaved: (newValue) {
                      update();
                    },
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Text('页码'),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    addPage(-1);
                  },
                ),
                Text(page.toString()),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    addPage(1);
                  },
                ),
              ],
            ),
            Row(
              children: [
                const Text('过滤：'),
                DropdownButton(
                  value: filter,
                  items: SearchFilter.values
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e.title)))
                      .toList(),
                  onChanged: (value) {
                    filter = value!;
                    update();
                  },
                )
              ],
            ),
            Row(
              children: [
                const Text('类型：'),
                DropdownButton(
                  value: category,
                  items: SearchCategory.values
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e.title)))
                      .toList(),
                  onChanged: (value) {
                    category = value!;
                    update();
                  },
                )
              ],
            ),
            Text(
              urlString,
              maxLines: 5,
              textAlign: TextAlign.start,
              style: const TextStyle(
                overflow: TextOverflow.fade,
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: sendRequest,
                  child: const Text('发送'),
                ),
              ],
            ),
            const Divider(),
            // 解析 View
            const Text(
              '解析 View',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            TextField(
              controller: viewUrl,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: sendDetailRequest,
                  child: const Text('解析'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
