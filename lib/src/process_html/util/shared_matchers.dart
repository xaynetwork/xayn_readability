/// A [RegExp] matcher for common video providers
final RegExp videoMatcher = RegExp(
    r'\/\/(www\.)?((dailymotion|youtube|youtube-nocookie|player\.vimeo|v\.qq)\.com|(archive|upload\.wikimedia)\.org|player\.twitch\.tv)',
    caseSensitive: false);
