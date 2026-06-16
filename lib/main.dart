import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'application/providers/alert_provider.dart';
import 'application/providers/analytics_provider.dart';
import 'application/providers/auth_provider.dart';
import 'application/providers/automation_provider.dart';
import 'application/providers/dashboard_provider.dart';
import 'application/providers/farm_layout_provider.dart';
import 'application/providers/irrigation_control_provider.dart';
import 'application/providers/schedule_provider.dart';
import 'application/providers/settings_provider.dart';
import 'application/providers/theme_provider.dart';
import 'application/providers/user_management_provider.dart';
import 'core/constants/app_strings.dart';
import 'core/routing/app_router.dart';
import 'core/services/api_client.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/farm_context.dart';
import 'core/services/local_cache_service.dart';
import 'core/services/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/api_alert_repository.dart';
import 'data/repositories/api_analytics_repository.dart';
import 'data/repositories/api_auth_repository.dart';
import 'data/repositories/api_dashboard_repository.dart';
import 'data/repositories/api_irrigation_repository.dart';
import 'data/repositories/api_schedule_repository.dart';
import 'data/repositories/api_user_repository.dart';
import 'data/repositories/mock_automation_repository.dart';

void main() {
  runApp(const SmartFarmApp());
}

class SmartFarmApp extends StatelessWidget {
  const SmartFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    final secureStorage = SecureStorageService();
    final cacheService = LocalCacheService();
    final connectivityService = ConnectivityService();
    final farmContext = FarmContext();
    final apiClient = ApiClient(secureStorage: secureStorage);

    return MultiProvider(
      providers: [
        Provider<SecureStorageService>.value(value: secureStorage),
        Provider<LocalCacheService>.value(value: cacheService),
        Provider<ConnectivityService>.value(value: connectivityService),
        Provider<FarmContext>.value(value: farmContext),
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            repository: ApiAuthRepository(
              apiClient: apiClient,
              secureStorage: secureStorage,
              farmContext: farmContext,
            ),
            secureStorage: secureStorage,
            farmContext: farmContext,
            userRepository: ApiUserRepository(apiClient: apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => UserManagementProvider(
            repository: ApiUserRepository(apiClient: apiClient),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(
            repository: ApiDashboardRepository(apiClient: apiClient, farmContext: farmContext),
            connectivityService: connectivityService,
            cacheService: cacheService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => IrrigationControlProvider(
            repository: ApiIrrigationRepository(apiClient: apiClient, farmContext: farmContext),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ScheduleProvider(
            repository: ApiScheduleRepository(apiClient: apiClient, farmContext: farmContext),
            connectivityService: connectivityService,
            cacheService: cacheService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AlertProvider(
            repository: ApiAlertRepository(apiClient: apiClient, farmContext: farmContext),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AnalyticsProvider(
            repository: ApiAnalyticsRepository(apiClient: apiClient, farmContext: farmContext),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AutomationProvider(repository: MockAutomationRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => FarmLayoutProvider(cacheService: cacheService)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            secureStorage: secureStorage,
            connectivityService: connectivityService,
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
            builder: (context, child) => ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: [
                const Breakpoint(start: 0, end: 599, name: MOBILE),
                const Breakpoint(start: 600, end: 1023, name: TABLET),
                const Breakpoint(start: 1024, end: double.infinity, name: DESKTOP),
              ],
            ),
          );
        },
      ),
    );
  }
}
