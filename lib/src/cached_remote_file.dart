import 'dart:async';
import 'dart:typed_data';
import 'package:cached_remote_file/src/debouncer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

/// A callback function that is called when the download progress changes.
///
/// The parameter `percentage` is the download percentage, from 0 to 100.
typedef CRFProgressValue = void Function(double percentage);

/// A class for fetching remote files and caching them locally.
///
/// This class allows you to download files from the internet and store them
/// locally, enhancing performance and reducing data usage.
class CachedRemoteFile {
  /// Creates a [CachedRemoteFile] instance with optional parameters.
  ///
  /// [cacheManager] is used for caching downloaded files. If not provided, it
  /// defaults to [DefaultCacheManager].
  ///
  /// [debouncer] is used for debouncing requests to prevent excessive
  /// concurrent requests. It can be customized with a specific debouncing
  /// delay to control how often requests are made.
  ///
  /// [httpClient] is used for making HTTP requests. If not provided,
  /// it defaults to [http.Client].
  CachedRemoteFile({
    BaseCacheManager? cacheManager,
    Debouncer? debouncer,
    http.Client? httpClient,
  })  : cacheManager = cacheManager ?? DefaultCacheManager(),
        debouncer =
            debouncer ?? Debouncer(delay: const Duration(milliseconds: 800)),
        httpClient = httpClient ?? http.Client();

  /// The cache manager used for caching downloaded files.
  final BaseCacheManager cacheManager;

  /// The HTTP client used for making HTTP requests.
  final http.Client httpClient;

  /// The debouncer used to control request frequency and prevent excessive
  /// concurrent requests.
  final Debouncer debouncer;

  /// Fetches a remote file from the specified [url].
  ///
  /// You can provide optional parameters to control the request and caching
  /// behavior:
  ///
  /// - [headers]: A map of HTTP headers to include in the request.
  /// - [process]: A callback to report the download progress as a percentage.
  /// - [progress]: A callback to report download progress with received and
  ///   total length.
  /// - [force]: Set to `true` to force a new download even if the file is
  ///   already cached.
  /// - [method]: The HTTP method to use for the request (e.g., 'GET', 'POST').
  /// - [debug]: Set to `true` to enable debugging output.
  /// - [timeout]: The maximum duration to wait for the request to complete.
  ///
  /// Returns a [Future] that completes with the downloaded file as a
  /// [Uint8List].
  Future<Uint8List> get(
    String url, {
    Map<String, String>? headers,
    CRFProgressValue? downloadProgressValue,
    bool force = false,
    String method = 'GET',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final completer = Completer<Uint8List>();
    debouncer.debounce(() async {
      final fileInfo = await cacheManager.getFileFromCache(url);
      bool isFileInCash;
      try {
        isFileInCash = fileInfo?.file.existsSync() ?? false;
      } catch (e) {
        isFileInCash = false;
      }
      if (!force && fileInfo != null && isFileInCash) {
        final bytes = await fileInfo.file.readAsBytes();
        completer.complete(Uint8List.fromList(bytes));
      } else {
        final request = http.Request(method, Uri.parse(url));
        if (headers != null) {
          request.headers.addAll(headers);
        }
        final bytesList = <int>[];
        var receivedLength = 0;

        try {
          final response = httpClient.send(request).timeout(timeout);
          response.asStream().listen(
            (http.StreamedResponse request) {
              request.stream.listen(
                (List<int> chunk) {
                  receivedLength += chunk.length;
                  final contentLength = request.contentLength ?? receivedLength;
                  final percentage = receivedLength / contentLength;
                  downloadProgressValue?.call(percentage);
                  bytesList.addAll(chunk);
                },
                onDone: () async {
                  final bytes = Uint8List.fromList(bytesList);
                  await cacheManager.putFile(url, bytes);
                  completer.complete(bytes);
                },
                onError: completer.completeError,
              );
            },
            onError: completer.completeError,
          );
        } catch (error) {
          completer.completeError(error);
        }
      }
    });
    return completer.future;
  }
}
