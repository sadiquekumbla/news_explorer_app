import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:news_explorer_app/providers/news_provider.dart';
import 'package:news_explorer_app/services/api_service.dart';
import 'package:news_explorer_app/services/sample_news_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => ApiService(),
        ),
        Provider(
          create: (_) => SampleNewsService(),
        ),
        ChangeNotifierProxyProvider2<ApiService, SampleNewsService, NewsProvider>(
          create: (context) => NewsProvider(
            context.read<ApiService>(),
            context.read<SampleNewsService>(),
          ),
          update: (context, apiService, sampleNewsService, previous) =>
              NewsProvider(apiService, sampleNewsService),
        ),
      ],
      child: MaterialApp(
        title: 'News Explorer',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
