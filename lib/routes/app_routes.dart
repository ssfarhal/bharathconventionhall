import 'package:go_router/go_router.dart';

import '../presentation/availability_calendar_screen/availability_calendar_screen.dart';
import '../presentation/booking_management_screen/booking_management_screen.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../widgets/app_scaffold.dart';

class AppRoutes {
  static const String initial = '/';
  static const String dashboardScreen = '/dashboard-screen';
  static const String availabilityCalendarScreen =
      '/availability-calendar-screen';
  static const String bookingManagementScreen = '/booking-management-screen';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.dashboardScreen,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboardScreen,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: DashboardScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.availabilityCalendarScreen,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: AvailabilityCalendarScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.bookingManagementScreen,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: BookingManagementScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
);
