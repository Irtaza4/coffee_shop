import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/coffee_repository.dart';
import 'presentation/viewmodels/shop_view_model.dart';
import 'presentation/views/onboarding_view.dart';
import 'presentation/views/shop_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ShopViewModel model = ShopViewModel(LocalCoffeeRepository());
  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Cuppio Coffee',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    builder: (context, child) => ColoredBox(
      color: const Color(0xFFEAF1F5),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: child!,
        ),
      ),
    ),
    home: ListenableBuilder(
      listenable: model,
      builder: (context, _) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: model.started
            ? ShopShell(key: const ValueKey('shop'), model: model)
            : OnboardingView(key: const ValueKey('welcome'), model: model),
      ),
    ),
  );
}
