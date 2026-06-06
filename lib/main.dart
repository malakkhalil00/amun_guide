// 📁 lib/main.dart
import 'package:flutter/material.dart';

// Core
import 'core/constants/app_colors.dart';
import 'core/constants/app_theme.dart';

// Auth
import 'screens/auth/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';

// Tourist
import 'screens/tourist/main_navigation.dart';
import 'screens/tourist/profile_screen.dart';
import 'screens/tourist/notifications_screen.dart';
import 'screens/tourist/edit_profile_screen.dart';
import 'screens/tourist/saved_places_screen.dart';
import 'screens/guide/guide_main_navigation.dart';

// Explore
import 'screens/explore/explore_screen.dart';
import 'screens/explore/place_details_screen.dart';
import 'screens/explore/tour_details_screen.dart';
import 'screens/explore/map_screen.dart';

// AI
import 'screens/ai/ai_chat_screen.dart';
import 'screens/ai/ai_plan_details_screen.dart';

// Payment
import 'screens/payment/complete_payment_screen.dart';
import 'screens/payment/my_payments_screen.dart';
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
import 'screens/general/about_Us_screen.dart';

import 'screens/guide/guide_tours_screen.dart';

import 'screens/booking/booking_summary_screen.dart';
import 'screens/booking/booking_confirmed_screen.dart';
import 'screens/booking/my_bookings_screen.dart';

void main() => runApp(const AmunGuideApp());

class AmunGuideApp extends StatelessWidget {
  const AmunGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amun Guide',
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      routes: {
        '/splash': (ctx) => const SplashScreen(),
        '/onboarding': (ctx) => const OnboardingScreen(),
        '/welcome': (ctx) => const WelcomeScreen(),
        '/register': (ctx) => const RegisterScreen(),
        '/forgot-password': (ctx) => ForgotPasswordScreen(),
        '/reset-password': (ctx) => const ResetPasswordScreen(),

        '/home': (ctx) => const MainNavigation(),
        '/guide-home': (ctx) => const GuideMainNavigation(),
        '/guide-tours': (ctx) => const GuideToursScreen(),

        '/notifications': (ctx) => const NotificationsScreen(),
        '/profile': (ctx) => const ProfileScreen(),
        '/edit-profile': (ctx) => const EditProfileScreen(),
        '/saved-places': (ctx) => const SavedPlacesScreen(),

        '/explore': (ctx) => const ExploreScreen(),
        '/place-details': (ctx) => const PlaceDetailsScreen(),
        '/tour-details': (ctx) => const TourDetailsScreen(),
        '/map': (ctx) => const MapScreen(tourTitle: '', places: []),

        '/ai-chat': (ctx) => const AiChatScreen(),
        '/ai-plan-details': (ctx) => const AiPlanDetailsScreen(),

        '/complete-payment': (ctx) {
          final args =
              ModalRoute.of(ctx)?.settings.arguments as Map<String, dynamic>?;
          return CompletePaymentScreen(
            bookingId: args?['bookingId'],
            amount: args?['amount']?.toDouble(),
            tourName: args?['tourName'],
          );
        },
        '/my-payments': (ctx) => const MyPaymentsScreen(),
        '/payment-success': (ctx) => const PaymentSuccessScreen(),
        '/payment-failed': (ctx) => const PaymentFailedScreen(),

        '/admin': (ctx) => const AdminDashboardScreen(),
        '/approve-payments': (ctx) => const ApprovePaymentsScreen(),
        '/create-tour': (ctx) => const CreateNewTourScreen(),
        '/manage-tours': (ctx) => const ManageToursScreen(),
        '/manage-users': (ctx) => const ManageUsersScreen(),

        '/community': (ctx) => const CommunityScreen(),
        '/post-details': (ctx) => const PostDetailsScreen(),
        '/about-us': (ctx) => const AboutUsScreen(),

        '/booking-summary': (ctx) => const BookingSummaryScreen(),
        '/booking-confirmed': (ctx) => const BookingConfirmedScreen(),
        '/my-bookings': (ctx) => const MyBookingsScreen(),
      },
    );
  }
}
