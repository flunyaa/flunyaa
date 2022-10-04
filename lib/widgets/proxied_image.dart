import 'package:flunyaa/utils/client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProxiedImageWidget extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  const ProxiedImageWidget({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<ProxiedImageWidget> createState() => _ProxiedImageWidgetState();
}

class _ProxiedImageWidgetState extends State<ProxiedImageWidget> {
  late String _url;
  late double? _width;
  late double? _height;
  late BoxFit _fit;
  late Widget _placeholder;
  late Widget _errorWidget;

  @override
  void initState() {
    super.initState();
    _url = widget.url;
    _width = widget.width;
    _height = widget.height;
    _fit = widget.fit;
    _placeholder = widget.placeholder ??
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
        );
    _errorWidget = widget.errorWidget ??
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
          ),
        );
  }

  Future<Uint8List> _loadImage() async {
    // TODO: 没有实现图片缓存
    final bytes = await NyaaClient.getBytes(Uri.parse(_url));
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return _placeholder;
          case ConnectionState.active:
            return _placeholder;
          case ConnectionState.waiting:
            return _placeholder;
          case ConnectionState.done:
            return Image.memory(
              snapshot.data as Uint8List,
              width: _width,
              height: _height,
              fit: _fit,
            );
          default:
            return _errorWidget;
        }
      },
      future: _loadImage(),
    );
  }
}
