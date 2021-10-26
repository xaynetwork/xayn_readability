import 'dart:math';

import 'package:html/dom.dart' as dom;
import 'package:reader_mode/src/process_html/objects/flag.dart';
import 'package:reader_mode/src/process_html/extensions/extensions.dart';
import 'package:reader_mode/src/process_html/objects/parser_options.dart';
import 'package:reader_mode/src/process_html/steps/check_byline.dart';
import 'package:reader_mode/src/process_html/steps/prep_article.dart';

final RegExp _unlikelyCandidatesMatcher = RegExp(
    r'-ad-|ai2html|banner|breadcrumbs|combx|comment|community|cover-wrap|disqus|extra|footer|gdpr|header|legends|menu|related|remark|replies|rss|shoutbox|sidebar|skyscraper|social|sponsor|supplemental|ad-break|agegate|pagination|pager|popup|yom-remote',
    caseSensitive: false);
final RegExp _candidateMatcher = RegExp(
    r'and|article|body|column|content|main|shadow',
    caseSensitive: false);

/// The main readability transform handler.
/// Attempts to convert the HTML from [document] into a reader mode digest version.
/// Pass [options] to adjust certain parameters which are used to run the transformer.
_GrabArticleResult grabArticle(
  final dom.Document document, {
  required ParserOptions options,
}) {
  const unlikelyRoles = [
    'menu',
    'menubar',
    'complementary',
    'navigation',
    'alert',
    'alertdialog',
    'dialog'
  ];
  const tagsToScore = [
    'section',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'p',
    'td',
    'pre'
  ];
  const alterDivToExceptions = ['DIV', 'ARTICLE', 'SECTION', 'P'];
  final flag = Flag();
  final attempts = <Map>[];
  final page = document.body!;
  final pageCacheHtml = page.innerHtml;
  String? articleByline, articleTitle;

  removeAndGetNext(dom.Element node) {
    final nextNode = node.getNextNode(true);

    node.remove();

    return nextNode;
  }

  while (true) {
    final stripUnlikelyCandidates = flag.isActive(Flag.stripUnlikely);
    // First, node prepping. Trash nodes that look cruddy (like ones with the
    // class name "comment", etc), and turn divs into P tags where they have been
    // used inappropriately (as in, where they contain no other block level elements.)
    final elementsToScore = <dom.Element>[];
    var node = document.documentElement;
    var shouldRemoveTitleHeader = true;

    while (node != null) {
      final matchString = '${node.className}_${node.id}';

      if (!node.isProbablyVisible) {
        node = removeAndGetNext(node);

        continue;
      }

      // Check to see if this node is a byline, and remove it if it is.
      final byline =
          checkByLine(node, match: matchString, articleByline: articleByline);

      if (byline.isByline) {
        articleByline = byline.value;

        node = removeAndGetNext(node);

        continue;
      }

      if (shouldRemoveTitleHeader && node.headerDuplicatesTitle(articleTitle)) {
        shouldRemoveTitleHeader = false;

        node = removeAndGetNext(node);

        continue;
      }

      // Remove unlikely candidates
      if (stripUnlikelyCandidates) {
        if (_unlikelyCandidatesMatcher.hasMatch(matchString) &&
            !_candidateMatcher.hasMatch(matchString) &&
            !node.hasAncestorTag(tagName: 'table') &&
            !node.hasAncestorTag(tagName: 'code') &&
            node.localName?.toLowerCase() != 'body' &&
            node.localName?.toLowerCase() != 'a') {
          node = removeAndGetNext(node);

          continue;
        }

        if (unlikelyRoles.contains(node.attributes['role']?.toLowerCase())) {
          node = removeAndGetNext(node);

          continue;
        }
      }

      const tagsToCheck = [
        'DIV',
        'SECTION',
        'HEADER',
        'H1',
        'H2',
        'H3',
        'H4',
        'H5',
        'H6'
      ];

      // Remove DIV, SECTION, and HEADER nodes without any content(e.g. text, image, video, or iframe).
      if (tagsToCheck.contains(node.localName?.toUpperCase()) &&
          node.isWithoutContent) {
        node = removeAndGetNext(node);

        continue;
      }

      if (tagsToScore.contains(node.localName?.toLowerCase())) {
        elementsToScore.add(node);
      }

      // Turn all divs that don't have children block level elements into p's
      if (node.localName?.toLowerCase() == 'div') {
        // Put phrasing content into paragraphs.
        dom.Element? p;
        var childNode = node.firstChild;

        while (childNode != null) {
          var nextSibling =
              (childNode is dom.Element) ? childNode.nextElementSibling : null;

          if (childNode.isPhrasingContent) {
            if (p != null) {
              p.append(childNode);
            } else if (!childNode.isWhitespace) {
              p = document.createElement('p');
              childNode.replaceWith(p);
              p.append(childNode);
            }
          } else if (p != null) {
            while (p.children.isNotEmpty && p.children.last.isWhitespace) {
              p.children.last.remove();
            }

            p = null;
          }

          childNode = nextSibling;
        }

        // Sites like http://mobile.slate.com encloses each paragraph with a DIV
        // element. DIVs with only a P element inside and no text content can be
        // safely converted into plain P elements to avoid confusing the scoring
        // algorithm with DIVs with are, in practice, paragraphs.
        //print('${node.localName}, ${node.hasSingleTag('p')}, ${node.linkDensity}');
        if (node.hasSingleTag('p') && node.linkDensity < .25) {
          final newNode = node.children.first;
          node.replaceWith(newNode);

          node = newNode;

          elementsToScore.add(node);
        } else if (!node.hasChildBlockElement) {
          node = node.swappedTagName(document, 'p');

          elementsToScore.add(node);
        }
      }

      node = node.getNextNode(false);
    }

    /**
     * Loop through all paragraphs, and assign a score to them based on how content-y they look.
     * Then add their score to their parent node.
     *
     * A score is determined by things like number of commas, class names, etc. Maybe eventually link density.
     **/
    var candidates = <dom.Element>[];

    for (var elementToScore in elementsToScore) {
      if (elementToScore.parentNode == null ||
          elementToScore.parentNode is! dom.Element) {
        continue;
      }

      // If this paragraph is less than 25 characters, don't even count it.
      var innerText = elementToScore.getInnerText(true);

      if (innerText.length < 25) {
        continue;
      }

      // Exclude nodes with no ancestor.
      final ancestors = elementToScore.getAncestors(5);

      if (ancestors.isEmpty) {
        continue;
      }

      var contentScore = .0;

      // Add a point for the paragraph itself as a base.
      contentScore += 1.0;

      // Add points for any commas within this paragraph.
      contentScore += innerText.split(',').length;

      // For every 100 characters in this paragraph, add another point. Up to 3 points.
      contentScore += min((innerText.length / 100).floor(), 3);

      // Initialize and score ancestors.
      for (var it in ancestors) {
        if (it.ancestor is! dom.Element ||
            it.ancestor.parentNode is! dom.Element) {
          continue;
        }

        if (!it.ancestor.hasReadability) {
          it.ancestor.initialize(flag);

          candidates.add(it.ancestor);
        }

        // Node score divider:
        // - parent:             1 (no division)
        // - grandparent:        2
        // - great grandparent+: ancestor level * 3
        var scoreDivider = 0;

        if (it.level == 0) {
          scoreDivider = 1;
        } else if (it.level == 1) {
          scoreDivider = 2;
        } else {
          scoreDivider = it.level * 3;
        }

        it.ancestor.setReadabilityContentScore(
            it.ancestor.readabilityContentScore + contentScore / scoreDivider);
      }
    }

    // After we've calculated scores, loop through all of the possible
    // candidate nodes we found and find the one with the highest score.
    final topCandidates = <dom.Element>[];

    for (var c = 0, cl = candidates.length; c < cl; c += 1) {
      var candidate = candidates[c];

      // Scale the final candidates score based on link density. Good content
      // should have a relatively small link density (5% or less) and be mostly
      // unaffected by this operation.
      var candidateScore =
          candidate.readabilityContentScore * (1.0 - candidate.linkDensity);

      candidate.setReadabilityContentScore(candidateScore);

      for (var t = 0, len = topCandidates.length;
          t < options.nTopCandidates;
          t++) {
        var aTopCandidate = t >= len - 1 ? null : topCandidates[t];

        if (aTopCandidate == null ||
            candidateScore > aTopCandidate.readabilityContentScore) {
          topCandidates.insert(t, candidate);

          if (topCandidates.length > options.nTopCandidates) {
            topCandidates.removeLast();
          }

          break;
        }
      }
    }

    var topCandidate = topCandidates.isNotEmpty ? topCandidates.first : null;
    var neededToCreateTopCandidate = false;
    dom.Element parentOfTopCandidate;

    // If we still have no top candidate, just use the body as a last resort.
    // We also have to copy the body node so it is something we can modify.
    if (topCandidate == null ||
        topCandidate.localName?.toUpperCase() == 'BODY') {
      // Move all of the page's children into topCandidate
      topCandidate = document.createElement('div');
      neededToCreateTopCandidate = true;
      // Move everything (not just elements, also text nodes etc.) into the container
      // so we even include text directly in the body:
      while (page.firstChild != null) {
        topCandidate.append(page.firstChild!);
      }

      page.append(topCandidate);

      topCandidate.initialize(flag);
    } else {
      // Find a better top candidate node if it contains (at least three) nodes which belong to `topCandidates` array
      // and whose scores are quite closed with current `topCandidate` node.
      var alternativeCandidateAncestors = <dom.Element>[];

      for (var i = 1, len = topCandidates.length; i < len; i++) {
        if (topCandidates[i].readabilityContentScore /
                topCandidate.readabilityContentScore >=
            .75) {
          alternativeCandidateAncestors
              .addAll(topCandidates[i].getAncestors().map((it) => it.ancestor));
        }
      }

      var minTopCandidates = 3;

      if (alternativeCandidateAncestors.length >= minTopCandidates) {
        parentOfTopCandidate = topCandidate.parent!;

        while (parentOfTopCandidate.localName?.toUpperCase() != 'BODY') {
          var listsContainingThisAncestor = 0;

          for (var ancestorIndex = 0;
              ancestorIndex < alternativeCandidateAncestors.length &&
                  listsContainingThisAncestor < minTopCandidates;
              ancestorIndex++) {
            listsContainingThisAncestor +=
                alternativeCandidateAncestors[ancestorIndex]
                        .contains(parentOfTopCandidate)
                    ? 1
                    : 0;
          }
          if (listsContainingThisAncestor >= minTopCandidates) {
            topCandidate = parentOfTopCandidate;
            break;
          }
          parentOfTopCandidate = parentOfTopCandidate.parent!;
        }
      }
      if (topCandidate != null && !topCandidate.hasReadability) {
        topCandidate.initialize(flag);
      }

      // Because of our bonus system, parents of candidates might have scores
      // themselves. They get half of the node. There won't be nodes with higher
      // scores than our topCandidate, but if we see the score going *up* in the first
      // few steps up the tree, that's a decent sign that there might be more content
      // lurking in other places that we want to unify in. The sibling stuff
      // below does some of that - but only if we've looked high enough up the DOM
      // tree.
      parentOfTopCandidate = topCandidate!.parent!;
      var lastScore = topCandidate.readabilityContentScore;
      // The scores shouldn't get too low.
      var scoreThreshold = lastScore / 3;
      while (parentOfTopCandidate.localName?.toUpperCase() != 'BODY') {
        if (!parentOfTopCandidate.hasReadability) {
          parentOfTopCandidate = parentOfTopCandidate.parent!;
          continue;
        }
        var parentScore = parentOfTopCandidate.readabilityContentScore;
        if (parentScore < scoreThreshold) {
          break;
        }
        if (parentScore > lastScore) {
          // Alright! We found a better parent to use.
          topCandidate = parentOfTopCandidate;
          break;
        }
        lastScore = parentOfTopCandidate.readabilityContentScore;
        parentOfTopCandidate = parentOfTopCandidate.parent!;
      }

      // If the top candidate is the only child, use parent instead. This will help sibling
      // joining logic when adjacent content is actually located in parent's sibling node.
      parentOfTopCandidate = topCandidate!.parent!;
      while (parentOfTopCandidate.localName?.toUpperCase() != 'BODY' &&
          parentOfTopCandidate.children.length == 1) {
        topCandidate = parentOfTopCandidate;
        parentOfTopCandidate = topCandidate.parent!;
      }
      if (!topCandidate!.hasReadability) {
        topCandidate.initialize(flag);
      }
    }

    // Now that we have the top candidate, look through its siblings for content
    // that might also be related. Things like preambles, content split by ads
    // that we removed, etc.
    var articleContent = document.createElement('div');

    articleContent.id = 'readability-content';

    var siblingScoreThreshold =
        max(10, topCandidate.readabilityContentScore * 0.2);
    // Keep potential top candidate's parent node to try to get text direction of it later.
    parentOfTopCandidate = topCandidate.parent!;
    var siblings = parentOfTopCandidate.children;

    for (var s = 0, sl = siblings.length; s < sl; s++) {
      var sibling = siblings[s];
      var append = false;

      if (sibling == topCandidate) {
        append = true;
      } else {
        var contentBonus = .0;

        // Give a bonus if sibling nodes and top candidates have the example same classname
        if (sibling.className == topCandidate.className &&
            topCandidate.className.isNotEmpty) {
          contentBonus += topCandidate.readabilityContentScore * 0.2;
        }

        if (sibling.hasReadability &&
            ((sibling.readabilityContentScore + contentBonus) >=
                siblingScoreThreshold)) {
          append = true;
        } else if (sibling.localName?.toUpperCase() == 'P') {
          var linkDensity = sibling.linkDensity;
          var nodeContent = sibling.getInnerText(true);
          var nodeLength = nodeContent.length;

          if (nodeLength > 80 && linkDensity < .25) {
            append = true;
          } else if (nodeLength < 80 &&
              nodeLength > 0 &&
              linkDensity == .0 &&
              RegExp(r'\.( |$)').hasMatch(nodeContent)) {
            append = true;
          }
        }
      }

      if (append) {
        if (!alterDivToExceptions
            .contains(sibling.localName?.trim().toUpperCase())) {
          // We have a node that isn't a common block level element, like a form or td tag.
          // Turn it into a div so it doesn't get filtered out later by accident.
          sibling = sibling.swappedTagName(document, 'div');
        }

        articleContent.append(sibling);
        // Fetch children again to make it compatible
        // with DOM parsers without live collection support.
        siblings = parentOfTopCandidate.children;
        // siblings is a reference to the children array, and
        // sibling is removed from the array when we call appendChild().
        // As a result, we must revisit this index since the nodes
        // have been shifted.
        s -= 1;
        sl -= 1;
      }
    }

    // So we have all of the content that we need. Now we clean it up for presentation.
    prepArticle(document, articleContent, options.baseUri, flag);

    if (neededToCreateTopCandidate) {
      // We already created a fake div thing, and there wouldn't have been any siblings left
      // for the previous loop, so there's no point trying to create a new div, and then
      // move all the children over. Just assign IDs and class names here. No need to append
      // because that already happened anyway.
      topCandidate.id = 'readability-page-1';
      topCandidate.className = 'page';
    } else {
      var div = document.createElement('div')
        ..id = 'readability-page-1'
        ..className = 'page';

      while (articleContent.firstChild != null) {
        div.append(articleContent.firstChild!);
      }

      articleContent.append(div);
    }

    var parseSuccessful = true;

    // Now that we've gone through the full algorithm, check to see if
    // we got any meaningful content. If we didn't, we may need to re-run
    // grabArticle with different flags set. This gives us a higher likelihood of
    // finding the content, and the sieve approach gives us a higher likelihood of
    // finding the -right- content.
    var textLength = articleContent.getInnerText(true).length;
    if (textLength < options.charThreshold) {
      parseSuccessful = false;
      page.innerHtml = pageCacheHtml;

      if (flag.isActive(Flag.stripUnlikely)) {
        flag.removeFlag(Flag.stripUnlikely);
        attempts
            .add({'articleContent': articleContent, 'textLength': textLength});
      } else if (flag.isActive(Flag.weightClasses)) {
        flag.removeFlag(Flag.weightClasses);
        attempts
            .add({'articleContent': articleContent, 'textLength': textLength});
      } else if (flag.isActive(Flag.cleanConditionally)) {
        flag.removeFlag(Flag.cleanConditionally);
        attempts
            .add({'articleContent': articleContent, 'textLength': textLength});
      } else {
        attempts
            .add({'articleContent': articleContent, 'textLength': textLength});
        // No luck after removing flags, just return the longest text we found during the different loops
        attempts.sort((a, b) {
          return b['textLength'] - a['textLength'];
        });

        // But first check if we actually have something
        if (!attempts.first.containsKey('textLength')) {
          return const _GrabArticleResult.empty();
        }

        articleContent = attempts.first['articleContent'];
        parseSuccessful = true;
      }
    }

    if (parseSuccessful) {
      // Find out text direction from ancestors of final top candidate.
      var ancestors = [
        parentOfTopCandidate,
        topCandidate,
        ...parentOfTopCandidate.getAncestors()
      ];

      ancestors.any((ancestor) {
        if (ancestor is! dom.Element) {
          return false;
        }

        var articleDir = ancestor.attributes['dir'];

        if (articleDir != null) {
          return true;
        }

        return false;
      });

      return _GrabArticleResult(element: articleContent, byLine: articleByline);
    }
  }
}

class _GrabArticleResult {
  final dom.Element? element;
  final String? byLine;

  const _GrabArticleResult({
    required this.element,
    required this.byLine,
  });

  const _GrabArticleResult.empty()
      : element = null,
        byLine = null;
}
