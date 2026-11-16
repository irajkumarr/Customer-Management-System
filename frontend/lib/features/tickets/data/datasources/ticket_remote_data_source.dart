import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/page_response.dart';
import '../models/message.dart';
import '../models/ticket.dart';
import '../models/ticket_detail.dart';
import '../models/ticket_enums.dart';
import '../models/ticket_stats.dart';

abstract class TicketRemoteDataSource {
  Future<PageResponse<Ticket>> getTickets({
    TicketStatus? status,
    TicketCategory? category,
    String? search,
    int page = 0,
    int size = 20,
  });

  Future<TicketStats> getStats();

  Future<TicketDetail> getTicketDetail(String id);

  Future<void> updateStatus(String id, TicketStatus status);

  Future<void> updateCategory(String id, TicketCategory category);

  Future<Message> sendAdminReply(String id, String body);
}

class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  final ApiClient apiClient;

  TicketRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PageResponse<Ticket>> getTickets({
    TicketStatus? status,
    TicketCategory? category,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': 'updatedAt,desc',
    };

    if (status != null) {
      queryParams['status'] = status.name;
    }
    if (category != null) {
      queryParams['category'] = category.name;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await apiClient.get<PageResponse<Ticket>>(
      ApiConstants.tickets,
      queryParameters: queryParams,
      fromJsonT: (json) => PageResponse<Ticket>.fromJson(
        json as Map<String, dynamic>,
        (item) => Ticket.fromJson(item as Map<String, dynamic>),
      ),
    );

    final data = response.data;
    if (data == null) {
      throw const ApiException(message: 'Failed to retrieve tickets.');
    }
    return data;
  }

  @override
  Future<TicketStats> getStats() async {
    final response = await apiClient.get<TicketStats>(
      ApiConstants.ticketStats,
      fromJsonT: (json) => TicketStats.fromJson(json as Map<String, dynamic>),
    );

    final data = response.data;
    if (data == null) {
      throw const ApiException(message: 'Failed to retrieve ticket statistics.');
    }
    return data;
  }

  @override
  Future<TicketDetail> getTicketDetail(String id) async {
    final response = await apiClient.get<TicketDetail>(
      ApiConstants.ticketDetail(id),
      fromJsonT: (json) => TicketDetail.fromJson(json as Map<String, dynamic>),
    );

    final data = response.data;
    if (data == null) {
      throw const ApiException(message: 'Failed to retrieve ticket details.');
    }
    return data;
  }

  @override
  Future<void> updateStatus(String id, TicketStatus status) async {
    await apiClient.patch<dynamic>(
      ApiConstants.ticketStatus(id),
      data: {'status': status.name},
      fromJsonT: (json) => json,
    );
  }

  @override
  Future<void> updateCategory(String id, TicketCategory category) async {
    await apiClient.patch<dynamic>(
      ApiConstants.ticketCategory(id),
      data: {'category': category.name},
      fromJsonT: (json) => json,
    );
  }

  @override
  Future<Message> sendAdminReply(String id, String body) async {
    final response = await apiClient.post<Message>(
      ApiConstants.ticketMessages(id),
      data: {
        'body': body.trim(),
        'resolveTicket': false,
      },
      fromJsonT: (json) => Message.fromJson(json as Map<String, dynamic>),
    );

    final data = response.data;
    if (data == null) {
      throw const ApiException(message: 'Failed to send admin reply.');
    }
    return data;
  }
}
