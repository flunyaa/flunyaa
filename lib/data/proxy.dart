import 'package:objectbox/objectbox.dart';

@Entity()
class ProxyConfiguration {
  @Id()
  int id = 0;
  String? type;
  String? host;
  int? port;
  String? username;
  String? password;
  bool selected = false;
}
