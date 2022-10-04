import 'package:flunyaa/data/proxy.dart';
import 'package:flunyaa/objectbox.g.dart';
import 'package:flunyaa/utils/client.dart';
import 'package:flunyaa/utils/db.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProxyPreferencesPage extends StatefulWidget {
  const ProxyPreferencesPage({super.key});

  @override
  State<ProxyPreferencesPage> createState() => _ProxyPreferencesPageState();
}

class _ProxyPreferencesPageState extends State<ProxyPreferencesPage> {
  // Proxy Box
  final _proxyBox = store.box<ProxyConfiguration>();
  // Proxy List
  List<ProxyConfiguration> _proxyList = [];

  int get _proxySelected => _proxyList
      .firstWhere(
        (element) => element.selected,
        orElse: () => ProxyConfiguration(),
      )
      .id;

  @override
  void initState() {
    super.initState();
    _loadProxies();
  }

  void _loadProxies() {
    final proxies = _proxyBox.query().build().find();
    _proxyList = proxies;
    setState(() {});
  }

  Future<ProxyConfiguration?> _showAddProxyDialog(BuildContext context) {
    final hostController = TextEditingController();
    final portController = TextEditingController();
    return showDialog<ProxyConfiguration>(
      context: context,
      builder: (context) {
        // Dialog
        String addSelectType = 'PROXY';
        return StatefulBuilder(builder: ((context, setState) {
          return AlertDialog(
            title: const Text('添加代理'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                  value: 'PROXY',
                  title: const Text('HTTP'),
                  groupValue: addSelectType,
                  onChanged: (value) {
                    addSelectType = value!;
                    setState(() {});
                  },
                ),
                RadioListTile(
                  value: 'SOCKS4',
                  title: const Text('SOCKS4'),
                  groupValue: addSelectType,
                  onChanged: (value) {
                    addSelectType = value!;
                    setState(() {});
                  },
                ),
                RadioListTile(
                  value: 'SOCKS5',
                  title: const Text('SOCKS5'),
                  groupValue: addSelectType,
                  onChanged: (value) {
                    addSelectType = value!;
                    setState(() {});
                  },
                ),
                TextField(
                  controller: hostController,
                  decoration: const InputDecoration(
                    hintText: '请输入代理地址',
                  ),
                ),
                TextField(
                  controller: portController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    // allow number from 1 to 65535
                    FilteringTextInputFormatter.allow(RegExp(
                        r'^([1-9](\d{0,3}))$|^([1-5]\d{4})$|^(6[0-4]\d{3})$|^(65[0-4]\d{2})$|^(655[0-2]\d)$|^(6553[0-5])$')),
                  ],
                  decoration: const InputDecoration(
                    hintText: '请输入代理端口',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('确定'),
                onPressed: () {
                  if (hostController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('代理地址不能为空'),
                      ),
                    );
                    return;
                  }
                  if (portController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('代理端口不能为空'),
                      ),
                    );
                    return;
                  }
                  final proxy = ProxyConfiguration()
                    ..type = addSelectType
                    ..host = hostController.text
                    ..port = int.parse(portController.text);
                  Navigator.of(context).pop(proxy);
                },
              ),
            ],
          );
        }));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('代理设置'),
        actions: [
          IconButton(
            tooltip: '删除选中代理',
            onPressed: () {
              if (_proxySelected == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('没有选中的代理'),
                  ),
                );
                return;
              } else {
                _proxyBox.remove(_proxySelected);
                _loadProxies();
              }
            },
            icon: const Icon(Icons.delete),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await _showAddProxyDialog(context);
              if (kDebugMode) {
                print(result);
              }
              if (result != null) {
                _proxyBox.put(result);
                _loadProxies();
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _proxyList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return RadioListTile(
              value: 0,
              groupValue: _proxySelected,
              title: const Text('DIRECT'),
              onChanged: (dynamic value) {
                if (kDebugMode) {
                  print('选中代理 ID：$value');
                }
                final allSelected = _proxyBox
                    .query(ProxyConfiguration_.selected.equals(true))
                    .build()
                    .find();
                for (final proxy in allSelected) {
                  proxy.selected = false;
                  _proxyBox.put(proxy);
                }
                NyaaClient.setProxy('DIRECT');
                _loadProxies();
              },
            );
          } else {
            final proxy = _proxyList[index - 1];
            return RadioListTile(
              value: proxy.id,
              groupValue: _proxySelected,
              title: Text('${proxy.type} ${proxy.host}:${proxy.port}'),
              onChanged: (value) {
                if (value is! int) {
                  return;
                }
                if (kDebugMode) {
                  print('选中代理 ID：$value');
                }
                final allSelected = _proxyBox.getAll();
                NyaaClient.setProxy(
                    '${proxy.type} ${proxy.host}:${proxy.port}');
                for (final p in allSelected) {
                  if (p.id == value) {
                    p.selected = true;
                    _proxyBox.put(p);
                  } else {
                    if (p.selected) {
                      p.selected = false;
                      _proxyBox.put(p);
                    }
                  }
                }
                _loadProxies();
              },
            );
          }
        },
      ),
    );
  }
}
