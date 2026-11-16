import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/network/page_response.dart';
import 'package:frontend/features/tickets/data/models/ticket_enums.dart';
import 'package:frontend/features/tickets/domain/entities/customer_entity.dart';
import 'package:frontend/features/tickets/domain/entities/message_entity.dart';
import 'package:frontend/features/tickets/domain/entities/ticket_detail_entity.dart';
import 'package:frontend/features/tickets/domain/entities/ticket_entity.dart';
import 'package:frontend/features/tickets/domain/entities/ticket_stats_entity.dart';
import 'package:frontend/features/tickets/domain/repositories/ticket_repository.dart';
import 'package:frontend/features/tickets/domain/usecases/get_ticket_detail_usecase.dart';
import 'package:frontend/features/tickets/domain/usecases/send_admin_reply_usecase.dart';
import 'package:frontend/features/tickets/domain/usecases/update_ticket_category_usecase.dart';
import 'package:frontend/features/tickets/domain/usecases/update_ticket_status_usecase.dart';
import 'package:frontend/features/tickets/presentation/bloc/ticket_detail_cubit.dart';
import 'package:frontend/features/tickets/presentation/bloc/ticket_detail_state.dart';

class FakeTicketDetailRepository implements TicketRepository {
  bool shouldFail = false;

  final sampleCustomer = CustomerEntity(
    id: 'cust-1',
    email: 'alice@example.com',
    name: 'Alice Johnson',
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  );

  late final TicketDetailEntity sampleDetail = TicketDetailEntity(
    id: 'ticket-1',
    customer: sampleCustomer,
    subject: 'Refund request',
    status: TicketStatus.ESCALATED_TO_HUMAN,
    category: TicketCategory.BILLING,
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
    messages: [
      MessageEntity(
        id: 'msg-1',
        ticketId: 'ticket-1',
        senderType: MessageSenderType.CUSTOMER,
        body: 'I was charged twice for subscription.',
        isAiGenerated: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      MessageEntity(
        id: 'msg-2',
        ticketId: 'ticket-1',
        senderType: MessageSenderType.AI,
        body: 'Thank you for reaching out. A human agent will review your billing issue.',
        isAiGenerated: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 59)),
      ),
    ],
  );

  @override
  Future<Either<Failure, TicketDetailEntity>> getTicketDetail(String id) async {
    if (shouldFail) {
      return const Left(ServerFailure(message: 'Ticket not found'));
    }
    return Right(sampleDetail);
  }

  @override
  Future<Either<Failure, void>> updateTicketStatus(String id, TicketStatus status) async {
    if (shouldFail) {
      return const Left(ServerFailure(message: 'Failed to update status'));
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateTicketCategory(String id, TicketCategory category) async {
    if (shouldFail) {
      return const Left(ServerFailure(message: 'Failed to update category'));
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, MessageEntity>> sendAdminReply(String id, String body) async {
    if (shouldFail) {
      return const Left(ServerFailure(message: 'Failed to send reply'));
    }
    return Right(
      MessageEntity(
        id: 'msg-admin-reply',
        ticketId: id,
        senderType: MessageSenderType.ADMIN,
        body: body,
        isAiGenerated: false,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Either<Failure, PageResponse<TicketEntity>>> getTickets({
    TicketStatus? status,
    TicketCategory? category,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TicketStatsEntity>> getStats() async {
    throw UnimplementedError();
  }
}

void main() {
  late FakeTicketDetailRepository fakeRepo;
  late TicketDetailCubit cubit;

  setUp(() {
    fakeRepo = FakeTicketDetailRepository();
    cubit = TicketDetailCubit(
      getTicketDetailUseCase: GetTicketDetailUseCase(fakeRepo),
      updateTicketStatusUseCase: UpdateTicketStatusUseCase(fakeRepo),
      updateTicketCategoryUseCase: UpdateTicketCategoryUseCase(fakeRepo),
      sendAdminReplyUseCase: SendAdminReplyUseCase(fakeRepo),
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state has TicketDetailStatus.initial', () {
    expect(cubit.state.status, TicketDetailStatus.initial);
    expect(cubit.state.ticket, isNull);
  });

  test('loadTicket loads ticket details and messages successfully', () async {
    await cubit.loadTicket('ticket-1');

    expect(cubit.state.status, TicketDetailStatus.success);
    expect(cubit.state.ticket?.id, 'ticket-1');
    expect(cubit.state.ticket?.messages.length, 2);
    expect(cubit.state.ticket?.status, TicketStatus.ESCALATED_TO_HUMAN);
  });

  test('refresh performs manual refresh on the current ticket', () async {
    await cubit.loadTicket('ticket-1');
    expect(cubit.state.status, TicketDetailStatus.success);

    await cubit.refresh();
    expect(cubit.state.status, TicketDetailStatus.success);
    expect(cubit.state.ticket?.messages.length, 2);
  });

  test('updateStatus changes status and emits success message', () async {
    await cubit.loadTicket('ticket-1');

    await cubit.updateStatus(TicketStatus.IN_PROGRESS);

    expect(cubit.state.ticket?.status, TicketStatus.IN_PROGRESS);
    expect(cubit.state.actionSuccessMessage?.contains('In Progress'), true);
  });

  test('updateCategory changes category and emits success message', () async {
    await cubit.loadTicket('ticket-1');

    await cubit.updateCategory(TicketCategory.TECHNICAL);

    expect(cubit.state.ticket?.category, TicketCategory.TECHNICAL);
    expect(cubit.state.actionSuccessMessage?.contains('Technical'), true);
  });

  test('sendReply appends admin reply and transitions status to IN_PROGRESS', () async {
    await cubit.loadTicket('ticket-1');
    expect(cubit.state.ticket?.messages.length, 2);

    final success = await cubit.sendReply('We have processed your refund.');

    expect(success, true);
    expect(cubit.state.ticket?.messages.length, 3);
    expect(cubit.state.ticket?.messages.last.senderType, MessageSenderType.ADMIN);
    expect(cubit.state.ticket?.messages.last.body, 'We have processed your refund.');
    // Automatic bump to IN_PROGRESS upon admin reply
    expect(cubit.state.ticket?.status, TicketStatus.IN_PROGRESS);
    expect(cubit.state.actionSuccessMessage?.contains('notified via email'), true);
  });

  test('loadTicket handles error gracefully', () async {
    fakeRepo.shouldFail = true;

    await cubit.loadTicket('ticket-1');

    expect(cubit.state.status, TicketDetailStatus.failure);
    expect(cubit.state.errorMessage, 'Ticket not found');
  });
}
