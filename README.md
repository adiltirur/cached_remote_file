# Cached Remote File

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]
[![codecov](https://codecov.io/gh/adiltirur/cached_remote_file/graph/badge.svg?token=X02CV3C8U8)](https://codecov.io/gh/adiltirur/cached_remote_file)
[![Release Workflow](https://github.com/adiltirur/cached_remote_file/actions/workflows/main.yaml/badge.svg)](https://github.com/adiltirur/cached_remote_file/actions/workflows/main.yaml)

`CachedRemoteFile` is a Flutter package for fetching remote files and caching them locally. It allows you to download files from the internet and store them locally, enhancing performance and reducing data usage. 
This Package also contains a debouncer class
This Package is inspired by [internet_file][internet_file]

## Installation

Install via `flutter pub add`:

```sh
dart pub add cached_remote_file
```
Then, run `flutter pub get` to fetch the package.

---

## Usage
Import the package and create an instance of `CachedRemoteFile` to start fetching and caching remote files.

```sh

import 'package:cached_remote_file/cached_remote_file.dart';

// Create a CachedRemoteFile instance
final cachedRemoteFile = CachedRemoteFile();

// Fetch a remote file and store it locally
final url = 'https://example.com/your-remote-file.txt';

try {
  final fileData = await cachedRemoteFile.get(url);
  if (fileData != null) {
    // Handle the downloaded file data (Uint8List)
  }
} catch (e) {
  // Handle errors
}

```
You can customize the behavior of the get method by providing optional parameters, such as headers, progress callbacks, and more.


```sh

// Example with optional parameters
final url = 'https://example.com/your-remote-file.txt';
final headers = {'Authorization': 'Bearer your_access_token'};

try {
  final fileData = await cachedRemoteFile.get(
    url,
    headers: headers,
    force: false,
    method: 'GET',
    timeout: const Duration(seconds: 30),
    downloadProgressValue: (double percentage) {
      // Handle download progress
    },
  );
  if (fileData != null) {
    // Handle the downloaded file data (Uint8List)
  }
} catch (e) {
  // Handle errors
}

```

## Documentation
For detailed information on the package and its classes, please refer to the [Dart documentation][dart-api-doc].

## License
This package is distributed under the MIT License. See the [LICENSE][license] file for more details.

[flutter_install_link]: https://docs.flutter.dev/get-started/install
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[testing-badge]: https://github.com/adiltirur/cached_remote_file/blob/main/coverage_badge.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://pub.dev/packages/very_good_cli
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[internet_file]: https://pub.dev/packages/internet_file
[dart-api-doc]: https://pub.dev/documentation/cached_remote_file/latest/
[license]: https://github.com/adiltirur/cached_remote_file/blob/master/LICENSE
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
