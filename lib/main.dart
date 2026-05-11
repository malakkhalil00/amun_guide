// 📁 lib/main.dart

import 'package:amin_gide/screens/general/about_us_screen.dart';
import 'package:flutter/material.dart';

// Core
import 'core/constants/app_colors.dart';

// Auth
import 'screens/auth/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/user_selection_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';

// Tourist
import 'screens/tourist/main_navigation.dart';
import 'screens/tourist/profile_screen.dart';
import 'screens/tourist/notifications_screen.dart';
import 'screens/tourist/edit_profile_screen.dart';
import 'screens/tourist/saved_places_screen.dart';

// Explore
import 'screens/explore/explore_screen.dart';
import 'screens/explore/place_details_screen.dart';
import 'screens/explore/tour_details_screen.dart';

// AI
import 'screens/ai/ai_chat_screen.dart';
import 'screens/ai/ai_plan_details_screen.dart';

// Payment
import 'screens/payment/payment_receipts_screen.dart';
import 'screens/payment/payment_success_screen.dart';
import 'screens/payment/payment_failed_screen.dart';

// Admin
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/approve_payments_screen.dart';
import 'screens/admin/create_new_tour_screen.dart';
import 'screens/admin/manage_tours_screen.dart';
import 'screens/admin/manage_users_screen.dart';

// General
import 'screens/general/community_screen.dart';
import 'screens/general/post_details_screen.dart';
import 'screens/general/about_us_screen.dart';
// import 'screens/payment/...';
// import 'screens/admin/...';
// import 'screens/general/...';

void main() => runApp(const AmunGuideApp());

class AmunGuideApp extends StatelessWidget {
  const AmunGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amun Guide',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark,
        primaryColor: AppColors.gold,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          surface: AppColors.bgCard,
        ),
      ),
      home: const SplashScreen(),
      routes: {

        // ══════════════════════════════════════
        // AUTH
        // splash → onboarding → welcome → user_selection
        //       → login → home
        //       → register → home
        //       → forgot_password → reset_password → login
        // ══════════════════════════════════════
        '/splash':          (ctx) => const SplashScreen(),
        '/onboarding':      (ctx) => const OnboardingScreen(),
        '/welcome':         (ctx) => const WelcomeScreen(),
        '/user-selection':  (ctx) => const UserSelectionScreen(),
        '/login':           (ctx) => const LoginScreen(),
        '/register':        (ctx) => const RegisterScreen(),
        '/forgot-password': (ctx) => ForgotPasswordScreen(),
        '/reset-password':  (ctx) => const ResetPasswordScreen(),

        // ══════════════════════════════════════
        // MAIN APP
        // ══════════════════════════════════════
        '/home':            (ctx) => const MainNavigation(),

        // ══════════════════════════════════════
        // TOURIST
        // ══════════════════════════════════════
        '/notifications':   (ctx) => const NotificationsScreen(),
        '/profile':          (ctx) => const ProfileScreen(),
        '/edit-profile':    (ctx) => const EditProfileScreen(),
        '/saved-places':    (ctx) => const SavedPlacesScreen(),

        // ══════════════════════════════════════
        // EXPLORE
        // ══════════════════════════════════════
        '/explore':         (ctx) => const ExploreScreen(),
        '/place-details':   (ctx) => const PlaceDetailsScreen(),
        '/tour-details':    (ctx) => const TourDetailsScreen(),

        // ══════════════════════════════════════
        // AI — يتضاف في Section 4
        // ══════════════════════════════════════
        '/ai-chat':         (ctx) => const AiChatScreen(),
        '/ai-plan-details': (ctx) => const AiPlanDetailsScreen(),

        // ══════════════════════════════════════
        // PAYMENT — يتضاف في Section 5
        // ══════════════════════════════════════
        '/payment-receipts': (ctx) => const PaymentReceiptsScreen(),
        '/payment-success':  (ctx) => const PaymentSuccessScreen(),
        '/payment-failed':   (ctx) => const PaymentFailedScreen(),

        // ══════════════════════════════════════
        // ADMIN — يتضاف في Section 6
        // ══════════════════════════════════════
        '/admin':            (ctx) => const AdminDashboardScreen(),
        '/approve-payments': (ctx) => const ApprovePaymentsScreen(),
        '/create-tour':      (ctx) => const CreateNewTourScreen(),
        '/manage-tours':     (ctx) => const ManageToursScreen(),
        '/manage-users':     (ctx) => const ManageUsersScreen(),

        // ══════════════════════════════════════
        // GENERAL — يتضاف في Section 7
        // ══════════════════════════════════════
        '/community':     (ctx) => const CommunityScreen(),
        '/post-details':  (ctx) => const PostDetailsScreen(),
        '/about-us':      (ctx) => const AboutUsScreen()
      },
    );
  }
}