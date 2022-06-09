import "dart:math";

const _randomArticleWebPages = [
  'https://www.newyorker.com/tech/elements/a-most-profound-math-problem',
];

Uri getRandomArticleUri() {
  final random = Random();
  var randomIndex = random.nextInt(_randomArticleWebPages.length);
  final randomUrl = _randomArticleWebPages[randomIndex];
  return Uri.parse(randomUrl);
}
