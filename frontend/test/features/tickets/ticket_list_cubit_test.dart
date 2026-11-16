import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/network/page_response.dart';
import 'package:frontend/features/tickets/data/models/ticket_enums.dart';
import 'package:frontend/features/tickets/domain/entities/message_entity.dart';
import 'package:frontend/features/tickets/domain/entities/ticket_detail_entity.dart';
import 'package:frontend/features/tickets/domain/entities/ticket_entity.dart';
import 'package:frontend/features/tickets/domain/entities/ticket_stats_entity.dart';
import 'package:frontend/features/tickets/domain/repositories/ticket_repository.dart';
import 'package:frontend/features/tickets/domain/usecases/get_ticket_stats_usecase.dart';
import 'package:frontend/features/tickets/domain/usecases/get_tickets_usecase.dart';
import 'package:frontend/features/tickets/presentation/bloc/ticket_list_cubit.dart';
import 'package:frontend/features/tickets/presentation/bloc/ticket_list_state.dart';

class FakeTicketRepository implements TicketRepository {
  bool shouldFail = false;

  final sampleTicket = TicketEntity(
    id: 'ticket-1',
    customerId: 'cust-1',
    customerEmail: 'customer@example.com',
    customerName: 'Alice Johnson',
    subject: 'Cannot login to account',
    status: TicketStatus.ESCALATED_TO_HUMAN,
    category: TicketCategory.ACCOUNT,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
  );

  final sampleStats = const TicketStatsEntity(
    total: 10,
    newTickets: 2,
    aiProcessing: 1,
    aiReplied: 3,
    escalatedToHuman: 2,
    inProgress: 1,
    resolved: 1,
    closed: 0,
    byCategory: {'ACCOUNT': 5, 'BILLING': 5},
  );

  @override
  Future<Either<Failure, PageResponse<TicketEntity>>> getTickets({
    TicketStatus? status,
    TicketCategory? category,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    if (shouldFail) {
      return const Left(ServerFailure(message: 'Failed to fetch tickets'));
    }
    return Right(
      PageResponse<TicketEntity>(
        content: [sampleTicket],
        totalElements: 1,
        totalPages: 1,
        size: 20,
        number: page,
        first: true,
        last: true,
        empty: false,
      ),
    );
  }

  @override
  Future<Either<Failure, TicketStatsEntity>> getStats() async {
    if (shouldFail) {
      return const Left(ServerFailure(message: 'Failed to fetch stats'));
    }
    return Right(sampleStats);
  }

  @override
  Future<Either<Failure, TicketDetailEntity>> getTicketDetail(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> updateTicketStatus(String id, TicketStatus status) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> updateTicketCategory(String id, TicketCategory category) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, MessageEntity>> sendAdminReply(String id, String body) async {
    throw UnimplementedError();
  }
}

void main() {
  late FakeTicketRepository fakeRepo;
  late TicketListCubit cubit;

  setUp(() {
    fakeRepo = FakeTicketRepository();
    cubit = TicketListCubit(
      getTicketsUseCase: GetTicketsUseCase(fakeRepo),
      getTicketStatsUseCase: GetTicketStatsUseCase(fakeRepo),
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state has TicketListStatus.initial', () {
    expect(cubit.state.status, TicketListStatus.initial);
    expect(cubit.state.tickets, isEmpty);
  });

  test('loadInitialData loads stats and tickets successfully', () async {
    await cubit.loadInitialData();

    expect(cubit.state.status, TicketListStatus.success);
    expect(cubit.state.tickets.length, 1);
    expect(cubit.state.tickets.first.subject, 'Cannot login to account');
    expect(cubit.state.stats, fakeRepo.sampleStats);
  });

  test('refresh performs manual refresh and preserves data', () async {
    await cubit.loadInitialData();
    expect(cubit.state.status, TicketListStatus.success);

    await cubit.refresh();
    expect(cubit.state.status, TicketListStatus.success);
    expect(cubit.state.tickets.length, 1);
  });

  test('setStatusFilter updates status filter and fetches page 0', () async {
    await cubit.setStatusFilter(TicketStatus.ESCALATED_TO_HUMAN);

    expect(cubit.state.selectedStatus, TicketStatus.ESCALATED_TO_HUMAN);
    expect(cubit.state.status, TicketListStatus.success);
    expect(cubit.state.currentPage, 0);
  });

  test('setCategoryFilter updates category filter', () async {
    await cubit.setCategoryFilter(TicketCategory.BILLING);

    expect(cubit.state.selectedCategory, TicketCategory.BILLING);
    expect(cubit.state.status, TicketListStatus.success);
  });

  test('setSearchQuery updates search query and re-fetches', () async {
    await cubit.setSearchQuery('login');

    expect(cubit.state.searchQuery, 'login');
    expect(cubit.state.status, TicketListStatus.success);
  });

  test('loadInitialData emits failure on repository error', () async {
    fakeRepo.shouldFail = true;

    await cubit.loadInitialData();

    expect(cubit.state.status, TicketListStatus.failure);
    expect(cubit.state.errorMessage, 'Failed to fetch tickets');
  });
}
