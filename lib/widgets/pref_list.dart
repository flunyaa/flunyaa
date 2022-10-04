import 'package:flunyaa/pages/development.dart';
import 'package:flunyaa/pages/proxy_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PrefListWidget extends StatelessWidget {
  const PrefListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final children = [
      ListTile(
        title: const Text('代理设置'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProxyPreferencesPage(),
            ),
          );
        },
      ),
      ListTile(
        title: const Text('关于'),
        onTap: () {},
      ),
    ];
    if (kDebugMode) {
      children.add(
        ListTile(
          title: const Text('开发者选项'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DevelopmentPage(),
              ),
            );
          },
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(top: 10),
      children: children,
    );
  }
}
