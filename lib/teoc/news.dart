/*
 * Teoc Launcher — titulares desde Google Noticias (RSS, sin API key).
 * Solo titulares cortos; al seleccionarlos se abre la nota completa.
 */

import 'dart:convert';
import 'dart:io';

class NewsItem {
  final String topic;
  final String title;
  final String source;
  final String link;
  final DateTime? published;

  const NewsItem(this.topic, this.title, this.source, this.link, this.published);

  String get age {
    final date = published;
    if (date == null) {
      return "";
    }
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return "hace ${diff.inMinutes.clamp(1, 59)} min";
    if (diff.inHours < 24) return "hace ${diff.inHours} h";
    return "hace ${diff.inDays} d";
  }
}

final Map<String, List<NewsItem>> _cache = {};
final Map<String, DateTime> _cacheTime = {};

Future<List<NewsItem>> fetchNewsForTopics(List<String> topics, {int perTopic = 3}) async {
  final results = await Future.wait(topics.map((topic) => _fetchTopic(topic, perTopic)));

  // Intercalar temas para que no salgan todos seguidos
  final List<NewsItem> mixed = [];
  int index = 0;
  bool added = true;
  while (added) {
    added = false;
    for (final list in results) {
      if (index < list.length) {
        mixed.add(list[index]);
        added = true;
      }
    }
    index++;
  }
  return mixed;
}

Future<List<NewsItem>> _fetchTopic(String topic, int limit) async {
  final cachedAt = _cacheTime[topic];
  if (cachedAt != null && DateTime.now().difference(cachedAt).inMinutes < 30) {
    return _cache[topic] ?? [];
  }

  final uri = Uri.https("news.google.com", "/rss/search", {
    "q": "$topic when:3d",
    "hl": "es-419",
    "gl": "CL",
    "ceid": "CL:es-419",
  });

  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 8);
  try {
    final request = await client.getUrl(uri);
    final response = await request.close().timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      return _cache[topic] ?? [];
    }
    final body = await response.transform(utf8.decoder).join();
    final items = _parse(topic, body, limit);
    _cache[topic] = items;
    _cacheTime[topic] = DateTime.now();
    return items;
  }
  catch (_) {
    return _cache[topic] ?? [];
  }
  finally {
    client.close();
  }
}

final RegExp _itemRegExp = RegExp(r"<item>([\s\S]*?)</item>");
final RegExp _titleRegExp = RegExp(r"<title>([\s\S]*?)</title>");
final RegExp _linkRegExp = RegExp(r"<link>([\s\S]*?)</link>");
final RegExp _dateRegExp = RegExp(r"<pubDate>([\s\S]*?)</pubDate>");
final RegExp _sourceRegExp = RegExp(r"<source[^>]*>([\s\S]*?)</source>");

List<NewsItem> _parse(String topic, String xml, int limit) {
  final List<NewsItem> items = [];
  for (final match in _itemRegExp.allMatches(xml)) {
    final block = match.group(1) ?? "";
    String title = _clean(_titleRegExp.firstMatch(block)?.group(1) ?? "");
    final link = _clean(_linkRegExp.firstMatch(block)?.group(1) ?? "");
    final source = _clean(_sourceRegExp.firstMatch(block)?.group(1) ?? "");
    final date = _parseDate(_dateRegExp.firstMatch(block)?.group(1));

    if (source.isNotEmpty && title.endsWith(" - $source")) {
      title = title.substring(0, title.length - source.length - 3);
    }
    if (title.isEmpty || link.isEmpty) {
      continue;
    }
    items.add(NewsItem(topic, title, source, link, date));
    if (items.length >= limit) {
      break;
    }
  }
  return items;
}

String _clean(String text) {
  var result = text.trim();
  if (result.startsWith("<![CDATA[")) {
    result = result.substring(9);
    if (result.endsWith("]]>")) {
      result = result.substring(0, result.length - 3);
    }
  }
  return result
      .replaceAll("&amp;", "&")
      .replaceAll("&quot;", "\"")
      .replaceAll("&#39;", "'")
      .replaceAll("&apos;", "'")
      .replaceAll("&lt;", "<")
      .replaceAll("&gt;", ">")
      .trim();
}

const _months = {
  "Jan": 1, "Feb": 2, "Mar": 3, "Apr": 4, "May": 5, "Jun": 6,
  "Jul": 7, "Aug": 8, "Sep": 9, "Oct": 10, "Nov": 11, "Dec": 12,
};

/// Formato RSS: "Mon, 19 Oct 2026 21:03:00 GMT"
DateTime? _parseDate(String? raw) {
  if (raw == null) {
    return null;
  }
  try {
    final parts = raw.trim().split(RegExp(r"\s+"));
    if (parts.length < 5) {
      return null;
    }
    final day = int.parse(parts[1]);
    final month = _months[parts[2]] ?? 1;
    final year = int.parse(parts[3]);
    final time = parts[4].split(":");
    return DateTime.utc(year, month, day, int.parse(time[0]), int.parse(time[1]),
        time.length > 2 ? int.parse(time[2]) : 0).toLocal();
  }
  catch (_) {
    return null;
  }
}
