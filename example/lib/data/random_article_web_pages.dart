import "dart:math";

const _randomArticleWebPages = [
  'https://www.newyorker.com/tech/elements/a-most-profound-math-problem',
  'https://www.prnewswire.com/news-releases/uc-berkeley-engages-seal-storage-web3-technology-to-advance-innovative-neutrino-physics-research-301564309.html',
  'https://www.thegamer.com/viral-video-draws-praise-for-red-dead-redemption-2s-physics/',
  'https://www.livescience.com/best-online-physics-courses',
  'https://www.housingwire.com/articles/its-math-how-mortgage-solutions-companies-are-fighting-for-survival/',
  'https://www.forbes.com/sites/dereknewton/2022/06/07/new-research-shows-a-way-to-close-learning-gaps-improve-math-proficiency/',
  'https://www.theverge.com/2022/6/7/23156300/wyze-scale-x-smart-scale-bia-babies-pets-price',
  'https://www.abqjournal.com/2504889/math-education-is-a-problem-nm-must-solve-2.html',
  'https://www.salon.com/2022/06/04/teaching-and-grieving-in-a-classroom-where-perfect-math-meets-a-broken-world/',
];

Uri getRandomArticleUri() {
  final random = Random();
  var randomIndex = random.nextInt(_randomArticleWebPages.length);
  final randomUrl = _randomArticleWebPages[randomIndex];
  return Uri.parse(randomUrl);
}
