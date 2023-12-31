import 'package:cached_remote_file/cached_remote_file.dart';
import 'package:cached_remote_file/src/debouncer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/file.dart' as file;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'cached_remote_file_test.mocks.dart';

@GenerateMocks([
  http.Client,
  BaseCacheManager,
  FileInfo,
  file.File,
])
Future<Uint8List> getPdfBytes() async {
  final data = await rootBundle.load('test/dummy.pdf');
  final bytes = data.buffer.asUint8List();
  return bytes;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final mockClient = MockClient(); // Mock the http client
  final mockCacheManager = MockBaseCacheManager(); // Mock the cache manager
  final remoteClient =
      CachedRemoteFile(httpClient: mockClient, cacheManager: mockCacheManager);

  group('Debouncer', () {
    test('debounce calls callback after delay', () async {
      // Create a Debouncer with a short delay
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));

      // Create a variable to store the execution count of the callback
      var executionCount = 0;

      // Call debounce with a callback function
      debouncer.debounce(() {
        executionCount++;
      });

      // Expect the execution count to be 0 before the delay
      expect(executionCount, 0);

      // Wait for a duration slightly longer than the debouncer's delay
      await Future.delayed(const Duration(milliseconds: 150), () {});

      // Expect the execution count to be 1 after the delay
      expect(executionCount, 1);
    });

    test('debounce cancels previous calls', () async {
      // Create a Debouncer with a longer delay
      final debouncer = Debouncer(delay: const Duration(milliseconds: 200));

      // Create a variable to store the execution count of the callback
      var executionCount = 0;

      // Call debounce with a callback function
      debouncer
        ..debounce(() {
          executionCount++;
        })

        // Call debounce again before the first delay completes
        ..debounce(() {
          executionCount++;
        });

      // Expect the execution count to be 0 before the delay
      expect(executionCount, 0);

      // Wait for a duration slightly longer than the debouncer's delay
      await Future.delayed(const Duration(milliseconds: 250), () {});

      // Expect the execution count to be 1 after the delay
      expect(executionCount, 1);
    });
  });
  group('download file from Internet', () {
    setUp(() async {
      final dummyPDF = await getPdfBytes();
      // Initialize the mock client and cache manager
      when(mockClient.send(argThat(anything))).thenAnswer(
        (_) async => http.StreamedResponse(Stream.value(dummyPDF), 400),
      );
      when(mockCacheManager.getFileFromCache(argThat(anything)))
          .thenAnswer((_) async => MockFileInfo());
      when(mockCacheManager.putFile(argThat(anything), argThat(anything)))
          .thenAnswer((_) async => MockFile());
    });

    test('Download Complete', () async {
      // Expect the download to complete successfully
      expect(await remoteClient.get('https://example.com'), isA<Uint8List>());
    });

    test('Complete with an error when an error occurs', () async {
      // Throw an error from the mock client
      when(mockClient.send(argThat(anything)))
          .thenThrow(Exception('Something went wrong'));

      // Expect the download to fail with the expected error message
      try {
        await remoteClient.get('https://example.com');
        fail('Expected error was not thrown');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Something went wrong'));
      }
    });

    test('Add headers to the request if headers are provided', () async {
      // Set headers for the request
      final headers = {'Authorization': 'Bearer Token'};

      // Expect the request to be made with the provided headers
      await remoteClient.get('https://example.com', headers: headers);

      verify(
        mockClient.send(
          argThat(
            predicate<http.Request>(
              (request) => request.headers['Authorization'] == 'Bearer Token',
            ),
          ),
        ),
      );
    });

    test('Download Progress Callback', () async {
      // Create a variable to store the last percentage value
      double? lastPercentage;

      // Download the file with a progress callback
      await remoteClient.get(
        'https://example.com',
        downloadProgressValue: (percentage) {
          lastPercentage = percentage;
        },
      );

      // Assert that the progress callback was called and
      //that the last percentage value is not null
      expect(lastPercentage, isNotNull);
    });
    test('HttpClient and CacheManager Initialization', () async {
      final remoteClient = CachedRemoteFile();

      expect(remoteClient.cacheManager, isA<BaseCacheManager>());
      expect(remoteClient.debouncer, isA<Debouncer>());
      expect(remoteClient.httpClient, isA<http.Client>());
    });
  });
}
