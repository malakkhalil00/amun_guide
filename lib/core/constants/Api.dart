class Api {
  static const String baseUrl = "https://amun-guide.up.railway.app";
  // ══════════════════════════════════════
  // AUTH
  // ══════════════════════════════════════
  static const String register = "/api/register";
  static const String login = "/api/login";
  static const String forgotPassword = "/api/forgot-password";
  static const String resetPassword = "/api/reset-password";

  // ══════════════════════════════════════
  // PLACES
  // ══════════════════════════════════════
  static const String places = "/api/v1/places";
  static String placeById(int id) => "/api/v1/places/$id";
  static const String trendingPlaces = "/api/v1/places/trending";
  static const String filterPlaces = "/api/v1/places/filter";
  static const String searchPlaces = "/api/v1/places/search";

  // ══════════════════════════════════════
  // TOURS
  // ══════════════════════════════════════
  static const String tours = "/api/v1/tours";
  static String tourById(int id) => "/api/v1/tours/$id";
  static const String myTours = "/api/v1/my-tours";
  static const String searchTours = "/api/v1/tours/search";
  static const String filterTours = "/api/v1/tours/filter";
  static const String popularTours = "/api/v1/tours/popular";
  static String guideTours(int guideId) => "/api/v1/tours/guide/$guideId";
  static String tourBookings(int tourId) => "/api/v1/tours/$tourId/bookings";

  // ══════════════════════════════════════
  // TOUR BOOKINGS
  // ══════════════════════════════════════
  static const String tourBookingsBase = "/api/v1/tour-bookings";
  static String tourBookingById(int id) => "/api/v1/tour-bookings/$id";
  static const String myBookings = "/api/v1/tour-bookings/my-bookings";
  static String tourBookingApprove(int id) =>
      "/api/v1/tour-bookings/$id/approve";
  static String tourBookingReject(int id) => "/api/v1/tour-bookings/$id/reject";
  static const String tourBookingStatistics =
      "/api/v1/tour-bookings/statistics";

  // ══════════════════════════════════════
  // COMMENTS
  // ══════════════════════════════════════
  static const String comments = "/api/v1/comments";
  static String commentById(int id) => "/api/v1/comments/$id";
  static String subjectComments(String type, int id) =>
      "/api/v1/$type/$id/comments";
  static String subjectCommentsCount(String type, int id) =>
      "/api/v1/$type/$id/comments/count";
  static String userComments(int userId) => "/api/v1/user/$userId/comments";

  // ══════════════════════════════════════
  // LIKES
  // ══════════════════════════════════════
  static const String likes = "/api/v1/likes";
  static const String likesToggle = "/api/v1/likes/toggle";
  static String likeById(int id) => "/api/v1/likes/$id";
  static String subjectLikes(String type, int id) => "/api/v1/$type/$id/likes";
  static String subjectLikesCount(String type, int id) =>
      "/api/v1/$type/$id/likes/count";
  static const String userLikes = "/api/v1/user/likes";

  // ══════════════════════════════════════
  // PAYMENTS
  // ══════════════════════════════════════
  static const String payments = "/api/v1/payments";
  static String paymentById(int id) => "/api/v1/payments/$id";
  static const String myPayments = "/api/v1/payments/my-payments";
  static String paymentApprove(int id) => "/api/v1/payments/$id/approve";
  static String paymentReject(int id) => "/api/v1/payments/$id/reject";
  static const String paymentStatistics = "/api/v1/payments/statistics";
  static const String paymentBulkApprove = "/api/v1/payments/bulk-approve";
  static String userPayments(int userId) => "/api/v1/users/$userId/payments";

  // ══════════════════════════════════════
  // CONVERSATIONS (AI CHAT)
  // ══════════════════════════════════════
  static const String conversations = "/api/v1/conversations";
  static String conversationById(int id) => "/api/v1/conversations/$id";
  static String conversationMessages(int id) =>
      "/api/v1/conversations/$id/messages";
  static String conversationImages(int id) =>
      "/api/v1/conversations/$id/images";
  static const String conversationStatistics =
      "/api/v1/conversations/statistics";

  // ══════════════════════════════════════
  // PLANS
  // ══════════════════════════════════════
  static const String plans = "/api/plans";
  static String planById(int id) => "/api/plans/$id";
  static const String myPlans = "/api/plans/my";

  // ══════════════════════════════════════
  // ANALYTICS
  // ══════════════════════════════════════
  static const String userActivity = "/api/v1/analysis/user_activity";
  static const String allUsersActivities = "/api/v1/analysis/users-all";
}
