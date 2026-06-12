import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/providers/calendar_provider.dart';
import 'core/providers/period_provider.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/registration_provider.dart';
import 'features/auth/pages/welcome_screen.dart';
import 'features/auth/pages/splash_page.dart';
import 'features/auth/pages/register_new_page.dart';
import 'features/auth/pages/register_chat_page.dart';
import 'features/home/pages/home_page.dart';
import 'package:flutter_application_1/shared/services/hive_service.dart';
import 'package:flutter_application_1/core/providers/moment_provider.dart';
import 'package:flutter_application_1/core/providers/notes_manager_provider.dart';
import 'package:flutter_application_1/shared/services/sync_service.dart';
import 'package:flutter_application_1/core/providers/couple_cache_provider.dart';
import 'package:flutter_application_1/core/services/event_bus.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/shared/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_application_1/core/providers/theme_provider.dart';
import 'package:flutter_application_1/features/auth/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  try {
    await Hive.initFlutter();
    await Hive.openBox('user_data');
    await Hive.openBox('period_data');
    await Hive.openBox('calendar_notes');
    await Hive.openBox('calendar_data');
    await ApiService.init();
    await HiveService.init();
    await Hive.openBox('sync_queue');
    await SyncService.init();
    await Hive.openBox('couple_cache');
  } catch (e) {
    debugPrint('❌ Hive Error: $e');
  }

  final appProvider = AppProvider();
  await appProvider.loadFromStorage();

  final prefs = await SharedPreferences.getInstance();

  final momentProvider = MomentProvider();

// 🔥 Listener: هر وقت partnerId پر شد، MomentProvider رو راه بنداز
  appProvider.addListener(() {
    if (appProvider.partnerId != null && appProvider.partnerId!.isNotEmpty) {
      if (!momentProvider.isInitialized) {
        momentProvider.init(); // 🔥 بدون پارامتر
      }
    }
  });

// اگه partnerId از الان موجود بود، همون اول راه بنداز
  if (appProvider.partnerId != null && appProvider.partnerId!.isNotEmpty) {
    momentProvider.init(); // 🔥 بدون پارامتر
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventBus()),
        ChangeNotifierProvider.value(value: appProvider),

        // 🔥 PeriodProvider با ProxyProvider
        ChangeNotifierProxyProvider<AppProvider, PeriodProvider>(
          create: (_) => PeriodProvider(),
          update: (_, appProvider, periodProvider) {
            // 🔥 فقط کاربران مونث باید دوره خودشون رو لود کنن
            if (appProvider.userId != null &&
                appProvider.gender == 'female' &&
                periodProvider!.currentUserId == null) {
              periodProvider.init(appProvider.userId!);
            }
            return periodProvider!;
          },
        ),

        ChangeNotifierProxyProvider<AppProvider, CalendarProvider>(
          create: (_) => CalendarProvider(),
          update: (_, appProvider, calendarProvider) {
            calendarProvider?.updateUserIds(
              userId: appProvider.userId,
              partnerId: appProvider.partnerId,
            );
            return calendarProvider!;
          },
        ),

        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => CoupleCacheProvider()),
        ChangeNotifierProvider.value(value: momentProvider),
        ChangeNotifierProvider(create: (_) => NotesManagerProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color pinkSaymo = AppColors.primary;
  static const Color darkText = Color(0xFF2D2D2D);
  static const Color bgLight = Color(0xFFFFFCFC);

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR'), Locale('en', 'US')],
      themeMode: themeProvider.themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },

      // 🔥 Dark Mode

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
        extensions: const [AppTheme.dark],
        scaffoldBackgroundColor: const Color(0xFF0A0A0A), // مشکی خیلی تیره
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary, // صورتی قدیمی
          secondary: AppColors.secondary, // بنفش قدیمی
          surface: Color(0xFF1A1A1A), // خاکستری تیره خنثی
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          error: AppColors.error,
        ),
        // دکمه‌ها
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        // نوار پایین
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          backgroundColor: Color(0xFF1A1A1A),
        ),
        // متن
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Vazir', color: Colors.white),
          bodyMedium: TextStyle(fontFamily: 'Vazir', color: Colors.white),
          bodySmall: TextStyle(fontFamily: 'Vazir', color: Colors.white70),
          titleLarge: TextStyle(fontFamily: 'Vazir', color: Colors.white),
          titleMedium: TextStyle(fontFamily: 'Vazir', color: Colors.white),
          titleSmall: TextStyle(fontFamily: 'Vazir', color: Colors.white70),
          labelLarge: TextStyle(fontFamily: 'Vazir', color: Colors.white),
          labelMedium: TextStyle(fontFamily: 'Vazir', color: Colors.white70),
          labelSmall: TextStyle(fontFamily: 'Vazir', color: Colors.white60),
        ),
        // کارت‌ها
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E), // کمی روشن‌تر از سطح اصلی
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        // دیالوگ‌ها
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          surfaceTintColor: Colors.transparent,
        ),
        // سوئیچ‌ها
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.primary;
            return Colors.grey;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected))
              return AppColors.primary.withOpacity(0.5);
            return Colors.grey.shade700;
          }),
        ),
        // اپ‌بار
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      // ☀️ تم روشن
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'Vazir',
        extensions: const [AppTheme.light],
        colorScheme: ColorScheme.fromSeed(
          seedColor: pinkSaymo,
          primary: pinkSaymo,
          onPrimary: Colors.white,
          surface: bgLight,
          onSurface: darkText,
        ),
        scaffoldBackgroundColor: bgLight,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: pinkSaymo,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge:
              TextStyle(fontFamily: 'Vazir', decoration: TextDecoration.none),
          bodyMedium:
              TextStyle(fontFamily: 'Vazir', decoration: TextDecoration.none),
          bodySmall:
              TextStyle(fontFamily: 'Vazir', decoration: TextDecoration.none),
          displayLarge:
              TextStyle(fontFamily: 'Vazir', decoration: TextDecoration.none),
          displayMedium:
              TextStyle(fontFamily: 'Vazir', decoration: TextDecoration.none),
          displaySmall:
              TextStyle(fontFamily: 'Vazir', decoration: TextDecoration.none),
          headlineLarge:
              TextStyle(fontFamily: 'Vazir', decoration: TextDecoration.none),
          headlineMedium:
              TextStyle(fontFamily: 'Vazir', decoration: TextDecoration.none),
          headlineSmall:
              TextStyle(fontFamily: 'Vazir', decoration: TextDecoration.none),
          titleLarge:
              TextStyle(fontFamily: 'Vazir', decoration: TextDecoration.none),
          titleMedium:
              TextStyle(fontFamily: 'Vazir', decoration: TextDecoration.none),
          titleSmall:
              TextStyle(fontFamily: 'Vazir', decoration: TextDecoration.none),
          labelLarge:
              TextStyle(fontFamily: 'Vazir', decoration: TextDecoration.none),
          labelMedium:
              TextStyle(fontFamily: 'Vazir', decoration: TextDecoration.none),
          labelSmall:
              TextStyle(fontFamily: 'Vazir', decoration: TextDecoration.none),
        ),
      ),

      home: appProvider.userId != null && appProvider.userId!.isNotEmpty
          ? const HomePage()
          : const SplashPage(),
      routes: {
        '/register': (context) => const RegisterNewPage(),
        '/register-chat': (context) => const RegisterChatPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
