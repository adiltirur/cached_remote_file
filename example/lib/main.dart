import 'package:cached_remote_file/cached_remote_file.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CachedRemoteFile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CachedRemoteFile'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final remoteFileDownloader = CachedRemoteFile();
  double _percentage = 0;
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Download Progress is ',
            ),
            Text(
              '${(_percentage * 100).toStringAsFixed(1)} %',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _downloadFile,
        tooltip: 'Download',
        child: _isDownloading
            ? CircularProgressIndicator(
                value: _percentage,
              )
            : const Icon(Icons.download),
      ),
    );
  }

  Future<void> _downloadFile() async {
    setState(() {
      _isDownloading = true;
    });
    await remoteFileDownloader.get(
      'https://link.testfile.org/PDF10MB',
      force: true,
      downloadProgressValue: (percentage) {
        setState(() {
          _percentage = percentage;
          if (percentage == 1.0) {
            _isDownloading = false;
          }
        });
      },
    );
  }
}
