import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:html/dom.dart' as dom;

import 'package:xayn_readability/src/process_html/steps/get_all_nodes_with_tag.dart';

final RegExp _jsonLdArticleTypesMatcher = RegExp(
    r'^Article|AdvertiserContentArticle|NewsArticle|AnalysisNewsArticle|AskPublicNewsArticle|BackgroundNewsArticle|OpinionNewsArticle|ReportageNewsArticle|ReviewNewsArticle|Report|SatiricalArticle|ScholarlyArticle|MedicalScholarlyArticle|SocialMediaPosting|BlogPosting|LiveBlogPosting|DiscussionForumPosting|TechArticle|APIReference$',
    caseSensitive: false);

/// Parses jsonLd within the [document] and returns the result as [Metadata]
Metadata getJsonLd(final dom.Document document) {
  final scripts =
      getAllNodesWithTag(node: document, tagNames: const ['script']);
  final jsonLdElement = scripts.firstWhereOrNull(
      (it) => it.attributes['type']?.toLowerCase() == 'application/ld+json');
  final markersExp = RegExp(r'^\s*<!\[CDATA\[|\]\]>\s*$');
  final schemaExp = RegExp(r'^https?\:\/\/schema\.org$');

  if (jsonLdElement != null) {
    try {
      // Strip CDATA markers if present
      final content = jsonLdElement.text.replaceAll(markersExp, '');
      Map? parsed = json.decode(content) as Map?;
      final String? contextValue = parsed!['@context'] as String?;
      var metadata = const Metadata();

      if (contextValue == null || !schemaExp.hasMatch(contextValue)) {
        return metadata;
      }

      final String? typeValue = parsed['@type'] as String?;
      final graphValue = parsed['@graph'] as Iterable?;

      if (typeValue == null && graphValue != null) {
        parsed = graphValue.cast<Map>().firstWhereOrNull((it) {
          final String typeValue = it['@type'] as String? ?? '';

          return _jsonLdArticleTypesMatcher.hasMatch(typeValue);
        });
      }

      if (parsed == null ||
          !parsed.containsKey('@type') ||
          !_jsonLdArticleTypesMatcher.hasMatch(parsed['@type'] as String)) {
        return metadata;
      }

      final name = parsed['name'] as String?,
          headline = parsed['headline'] as String?,
          authorAsString = parsed['author'] as String?,
          authorAsIterable = parsed['author'] as Iterable?,
          description = parsed['description'] as String?,
          publisher = parsed['publisher'] as String?;

      if (name is String) {
        metadata = metadata.withTitle(name.trim());
      } else if (headline is String) {
        metadata = metadata.withTitle(headline.trim());
      }

      if (authorAsString != null) {
        metadata = metadata.withByline(authorAsString.trim());
      } else if (authorAsIterable != null &&
          authorAsIterable.isNotEmpty &&
          authorAsIterable.first is String) {
        metadata = metadata.withByline(authorAsIterable
            .whereType<String>()
            .map((it) => it.trim())
            .join(', '));
      }

      if (description is String) {
        metadata = metadata.withExcerpt(description.trim());
      }

      if (publisher is String) {
        metadata = metadata.withSiteName(publisher.trim());
      }

      return metadata;
    } catch (err) {
      log(err.toString());
    }
  }

  return const Metadata();
}

/// A collection of values that were discovered from parsing jsonLd
class Metadata {
  /// The title that was discovered
  final String? title;

  /// The byline that was discovered
  final String? byline;

  /// The excerpt that was discovered
  final String? excerpt;

  /// The siteName that was discovered
  final String? siteName;

  /// Constructs a new Metadata object with values as discovered from paring jsonLd.
  const Metadata({
    this.title,
    this.byline,
    this.excerpt,
    this.siteName,
  });

  /// Transforms only the [title] value and returns the adjusted [Metadata]
  Metadata withTitle(final String value) => Metadata(
        title: value,
        byline: byline,
        excerpt: excerpt,
        siteName: siteName,
      );

  /// Transforms only the [byline] value and returns the adjusted [Metadata]
  Metadata withByline(final String value) => Metadata(
        title: title,
        byline: value,
        excerpt: excerpt,
        siteName: siteName,
      );

  /// Transforms only the [excerpt] value and returns the adjusted [Metadata]
  Metadata withExcerpt(final String value) => Metadata(
        title: title,
        byline: byline,
        excerpt: value,
        siteName: siteName,
      );

  /// Transforms only the [siteName] value and returns the adjusted [Metadata]
  Metadata withSiteName(final String value) => Metadata(
        title: title,
        byline: byline,
        excerpt: excerpt,
        siteName: value,
      );

  @override
  String toString() => {
        'title': title,
        'byline': byline,
        'excerpt': excerpt,
        'siteName': siteName,
      }.toString();
}
