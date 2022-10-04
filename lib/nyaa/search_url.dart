import 'package:flunyaa/utils/enums.dart';

class SearchURLBuilder {
  static const String domain = 'nyaa.si';
  String query; // q={query}
  SearchFilter filter; // f={filter}
  SearchCategory category; // c={category}_{sub-category}
  int _page; // p={page}

  int get page => _page;

  SearchURLBuilder({
    this.query = '',
    this.filter = SearchFilter.noFilter,
    this.category = SearchCategory.all,
    page = 1,
  }) : _page = page;

  SearchURLBuilder.query(String query) : this(query: query);

  SearchURLBuilder setPage(int page) {
    if (page > 0) {
      _page = page;
    }
    return this;
  }

  SearchURLBuilder nextPage() {
    _page++;
    return this;
  }

  SearchURLBuilder prevPage() {
    if (_page > 1) _page--;
    return this;
  }

  SearchURLBuilder setQuery(String query) {
    this.query = query;
    return this;
  }

  SearchURLBuilder setFilter(SearchFilter filter) {
    this.filter = filter;
    return this;
  }

  SearchURLBuilder setCategory(SearchCategory category) {
    this.category = category;
    return this;
  }

  Uri toUri() {
    Map<String, String> map = {};
    if (query.isNotEmpty) {
      map.addAll({'q': query});
    }
    if (filter != SearchFilter.noFilter) {
      map.addAll({'f': filter.value.toString()});
    }
    if (category != SearchCategory.all) {
      map.addAll({'c': category.category});
    }
    if (_page > 1) {
      map.addAll({'p': _page.toString()});
    }
    Uri uri = Uri.https(domain, '/', map.isNotEmpty ? map : null);
    return uri;
  }

  @override
  String toString() {
    Uri url = toUri();
    return url.toString();
  }
}
