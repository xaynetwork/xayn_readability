# xayn_readability

[![Pub](https://img.shields.io/pub/v/xayn_readability.svg)](https://pub.dartlang.org/packages/xayn_readability)
[![codecov](https://codecov.io/gh/xaynetwork/xayn_readability/branch/main/graph/badge.svg)](https://codecov.io/gh/xaynetwork/xayn_readability)
[![Build Status](https://github.com/xaynetwork/xayn_readability/actions/workflows/flutter_post_merge.yaml/badge.svg)](https://github.com/xaynetwork/xayn_readability/actions)

Xayn readability provides the [reader mode widget](./lib/src/widgets/reader_mode.dart), which renders html content as pure Flutter widgets.

The project transforms html content into `readable` html content, using a native dart port of
[Mozilla's fantastic readability project](https://github.com/mozilla/readability).

The rendering to Flutter widgets is done using another great open source project, [flutter_widget_from_html_core](https://pub.dev/packages/flutter_widget_from_html_core).


----------



## Table of content:

 * [Installing :hammer_and_wrench:](#installing-hammer_and_wrench)
 * [How to use :building_construction:](#how-to-use-building_construction)
 * [Visuals :heart_eyes_cat:](#visuals-heart_eyes_cat)
 * [Attributes :gear:](#attributes-gear)
 * [Troubleshooting :thinking:](#troubleshooting-thinking)
 * [Contributing :construction_worker_woman:](#contributing-construction_worker_woman)
 * [License :scroll:](#license-scroll)

----------



## Installing :hammer_and_wrench:

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  xayn_readability: `latest version`
```

after that, shoot it on the command line:

```shell
$ flutter pub get
```

----------



## How to use :building_construction:

Use case #1 (short description)
```dart
	// add some code with ninja-comments here
```

Use case #2 (short description)
```dart
	// add some code with ninja-comments here
```

Use case #3 (short description)
```dart
	// add some code with ninja-comments here
```

 - try out the [example](./example/lib/main.dart)

[top :arrow_heading_up:](#xayn_readability)

----------



## Attributes :gear:

| attribute name   | Datatype		| Default Value | Description                                  |
| ---------------- | -------------- | ------------- | -------------------------------------------- |
| `child`          | `Widget`   	| `required`    | The widget below this widget in the tree.    |
| `isEnabled`      | `bool`   	 	| `true`    	| Responsible for showing component as enabled.|
| `key` 		   | `Key`          | `null`        | Controls how one widget replaces another widget in the tree. |

[top :arrow_heading_up:](#xayn_readability)

----------



## Troubleshooting :thinking:

Describe here well known problems and how they can be solved.

[top :arrow_heading_up:](#xayn_readability)

----------



## Contributing :construction_worker_woman:

We're more than happy to accept pull requests :muscle:

 - check our [contributing](../main/.github/contributing.md) page
 - found a bug or have a question? Please [create an issue](https://github.com/xaynetwork/xayn_readability/issues/new/choose).



[top :arrow_heading_up:](#xayn_readability)

----------



## License :scroll:
**xayn_readability** is licensed under `Apache 2`. View [license](../main/LICENSE).

[top :arrow_heading_up:](#xayn_readability)

----------


