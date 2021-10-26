## :bangbang: TO-DO list after creating repo from template:

 - [ ] Create new flutter project
 - [ ] [Organizing a library package](https://dart.dev/guides/libraries/create-library-packages#organizing-a-library-package)
 - [ ] Replace all `project_name` with the corrent one in this file
 - [ ] Replace `repo name` with the corrent one in:
   - [ ] this filein the 
   - [ ] [contributing](#contributing-construction_worker_woman) `create an issue` link
 - [ ] Remove useless parts of this README
 - [ ] Check license
 - [ ] Specifying a plugin’s supported platforms. More [here](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms)
 - [ ] Uncomment CI scripts in `.github/workflows` 
   - [ ] Set the latest `Flutter version` inside all of them
- [ ] Setup `repository settings` - branch rules, PR reviews, etc. Sadly, but it's not copied from the template repo... 
 - [ ] to enable `codeCov` - please ask Felix to enable it for this repository
 - [ ] Try to keep README page SIMPLE but USEFUL
 - [ ] Chgeck for [PUB POINTS](https://pub.dev/help/scoring#pub-points)
   - [ ] Follow Dart file conventions(https://pub.dev/help/scoring#follow-dart-file-conventions)  (this one done, but doubel-check it)
   - [ ] [Provide documentation](https://pub.dev/help/scoring#provide-documentation)
   - [ ] [Support multiple platforms](https://pub.dev/help/scoring#support-multiple-platforms)
   - [ ] [Pass static analysis](https://pub.dev/help/scoring#pass-static-analysis)
   - [ ] [Support up-to-date dependencies](https://pub.dev/help/scoring#support-up-to-date-dependencies)
   - [ ] [View pub points report](https://pub.dev/help/scoring#calculating-pub-points-prior-to-publishing) before publishing. Make sure we have all possible score :muscle:
 - [ ] Remove this `TODO list` from the ReadMe, when all above are done :wink:

----------

# project_name

[![Pub](https://img.shields.io/pub/v/project_name.svg)](https://pub.dartlang.org/packages/project_name)
[![codecov](https://codecov.io/gh/xaynetwork/flutter-open-source-repo-template/branch/main/graph/badge.svg)](https://codecov.io/gh/xaynetwork/flutter-open-source-repo-template)
[![Build Status](https://github.com/xaynetwork/flutter-open-source-repo-template/actions/workflows/flutter_post_merge.yaml/badge.svg)](https://github.com/xaynetwork/flutter-open-source-repo-template/actions)

Short description of the project: What, Why, When and How :rofl:


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
  project_name: `latest version`
```

after that, shoot it on the command line:

```css
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

 - please also give a try to the [example app](../main/example/) :stuck_out_tongue_winking_eye:
 - check full [documentation here](../documentation/)

[top :arrow_heading_up:](#project_name)

----------

## Visuals :heart_eyes_cat:

Curious how it will be looking? :smirk:

 |                          |                          |
 | ------------------------ | ------------------------ |
 | case description #1      | case description #2      |
 | <img width="280" src="../main/visuals/coding.gif"> | <img width="280" src="../main/visuals/building.gif"> |
 |                          |                          |
 | case description #3      | case description #4      |
 | <img width="280" src="../main/visuals/tea.gif"> | <img width="280" src="../main/visuals/cosmos.gif"> |

[top :arrow_heading_up:](#project_name)

----------



## Attributes :gear:

| attribute name   | Datatype		| Default Value | Description                                  |
| ---------------- | -------------- | ------------- | -------------------------------------------- |
| `child`          | `Widget`   	| `required`    | The widget below this widget in the tree.    |
| `isEnabled`      | `bool`   	 	| `true`    	| Responsible for showing component as enabled.|
| `key` 		   | `Key`          | `null`        | Controls how one widget replaces another widget in the tree. |

[top :arrow_heading_up:](#project_name)

----------



## Troubleshooting :thinking:

Describe here well known problems and how they can be solved.

[top :arrow_heading_up:](#project_name)

----------



## Contributing :construction_worker_woman:

We're more than happy to accept pull requests :muscle:

 - check our [contributing](../main/.github/contributing.md) page
 - found a bug or have a question? Please [create an issue](https://github.com/xaynetwork/flutter-open-source-repo-template/issues/new/choose).



[top :arrow_heading_up:](#project_name)

----------



## License :scroll:
**project_name** is licensed under `Apache 2`. View [license](../main/LICENSE).

[top :arrow_heading_up:](#project_name)

----------


