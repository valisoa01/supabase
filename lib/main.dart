import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/posts/presentation/post_providers.dart';
import 'features/posts/data/post_local_datasource.dart';
import 'features/auth/presentation/auth_providers.dart';

late final Box<String> _tasksBox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Hive.initFlutter();
  _tasksBox = await Hive.openBox<String>('posts_cache');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        postLocalDataSourceProvider.overrideWithValue(
          PostLocalDataSource(_tasksBox),
        ),
      ],
      child: MaterialApp(
        title: 'NextFlutter App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }
}
