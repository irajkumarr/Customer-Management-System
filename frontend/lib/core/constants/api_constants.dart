class ApiConstants {
  ApiConstants._();

  // Base URL (defaults to localhost:8080, can be overridden via environment)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String authStatus = '/api/auth/status';
  static const String authMe = '/api/auth/me';

  // Ticket endpoints
  static const String tickets = '/api/tickets';
  static const String ticketStats = '/api/tickets/stats';

  static String ticketDetail(String id) => '/api/tickets/$id';
  static String ticketStatus(String id) => '/api/tickets/$id/status';
  static String ticketCategory(String id) => '/api/tickets/$id/category';
  static String ticketMessages(String id) => '/api/tickets/$id/messages';

  // Customer endpoints
  static const String customers = '/api/customers';
  static String customerDetail(String id) => '/api/customers/$id';
}
