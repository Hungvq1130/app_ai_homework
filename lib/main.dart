import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'history_store.dart';
import 'splash_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HistoryStore.initSession();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/translations',     // thư mục chứa en.json, vi.json
      fallbackLocale: const Locale('vi'),
      useOnlyLangCode: true,
      saveLocale: true,                // nhớ ngôn ngữ đã chọn
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo Splash',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),

      // 🔽 Kết nối với easy_localization
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      navigatorObservers: [routeObserver],

      // ⚠️ Giữ nguyên flow của bạn: SplashScreen là entry
      home: const SplashScreen(),
    );
  }
}
