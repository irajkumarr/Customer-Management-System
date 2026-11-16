import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/network/page_response.dart';
import 'package:frontend/features/auth/domain/entities/admin.dart';
import 'package:frontend/features/auth/domain/entities/admin_role.dart';
import 'package:frontend/features/auth/domain/entities/session_status_entity.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/check_session_status_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_admin_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:frontend/features/tickets/data/models/ticket_enums.dart';
import 'package:frontend/features/tickets/domain/entities/customer_entity.dart';
import 'package:frontend/features/tickets/domain/entities/message_entity.dart';
import 'package:frontend/features/tickets/domain/entities/ticket_detail_entity.dart';
import 'package:frontend/features/tickets/domain/entities/ticket_entity.dart';
import 'package:frontend/features/tickets/domain/entities/ticket_stats_entity.dart';
import 'package:frontend/features/tickets/domain/repositories/ticket_repository.dart';
import 'package:frontend/features/tickets/domain/usecases/get_ticket_detail_usecase.dart';
import 'package:frontend/features/tickets/domain/usecases/get_ticket_stats_usecase.dart';
import 'package:frontend/features/tickets/domain/usecases/get_tickets_usecase.dart';
import 'package:frontend/features/tickets/domain/usecases/send_admin_reply_usecase.dart';
import 'package:frontend/features/tickets/domain/usecases/update_ticket_category_usecase.dart';
import 'package:frontend/features/tickets/domain/usecases/update_ticket_status_usecase.dart';
import 'package:frontend/features/tickets/presentation/bloc/ticket_detail_cubit.dart';
import 'package:frontend/features/tickets/presentation/bloc/ticket_list_cubit.dart';
import 'package:frontend/features/tickets/presentation/pages/ticket_dashboard_page.dart';
import 'package:frontend/features/tickets/presentation/pages/ticket_detail_page.dart';
import 'package:frontend/features/tickets/presentation/widgets/admin_reply_bar.dart';
import 'package:frontend/features/tickets/presentation/widgets/app_sidebar.dart';
import 'package:frontend/features/tickets/presentation/widgets/ticket_detail_pane.dart';
import 'package:frontend/features/tickets/presentation/widgets/ticket_list_pane.dart';

class FakeAuthRepository implements AuthRepository {
  final Admin admin = const Admin(
    id: '00000000-0000-0000-0000-000000000001',
    username: 'admin',
    role: AdminRole.ADMIN,
  );

  @override
  Future<Either<Failure, Admin>> login({required String username, required String password}) async =>
      Right(admin);

  @override
  Future<Either<Failure, SessionStatusEntity>> checkSessionStatus() async =>
      const Right(SessionStatusEntity(isAuthenticated: true, username: 'admin', role: 'ADMIN'));

  @override
  Future<Either<Failure, Admin>> getCurrentAdmin() async => Right(admin);

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);
}

class FakeTicketRepository implements TicketRepository {
  final sampleCustomer = CustomerEntity(
    id: 'cust-1',
    email: 'customer@example.com',
    name: 'Alice Johnson',
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  );

  final sampleTicket = TicketEntity(
    id: '1',
    customerId: 'cust-1',
    customerEmail: 'customer@example.com',
    customerName: 'Alice Johnson',
    subject: 'Billing issue with renewal',
    status: TicketStatus.ESCALATED_TO_HUMAN,
    category: TicketCategory.BILLING,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    updatedAt: DateTime.now(),
  );

  late final TicketDetailEntity sampleDetail = TicketDetailEntity(
    id: '1',
    customer: sampleCustomer,
    subject: 'Billing issue with renewal',
    status: TicketStatus.ESCALATED_TO_HUMAN,
    category: TicketCategory.BILLING,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    updatedAt: DateTime.now(),
    messages: [
      MessageEntity(
        id: 'msg-1',
        ticketId: '1',
        senderType: MessageSenderType.CUSTOMER,
        body: 'Hello, I was charged twice for renewal.',
        isAiGenerated: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
      ),
    ],
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
    byCategory: {'BILLING': 10},
  );

  @override
  Future<Either<Failure, PageResponse<TicketEntity>>> getTickets({
    TicketStatus? status,
    TicketCategory? category,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
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
  Future<Either<Failure, TicketStatsEntity>> getStats() async => Right(sampleStats);

  @override
  Future<Either<Failure, TicketDetailEntity>> getTicketDetail(String id) async => Right(sampleDetail);

  @override
  Future<Either<Failure, void>> updateTicketStatus(String id, TicketStatus status) async => const Right(null);

  @override
  Future<Either<Failure, void>> updateTicketCategory(String id, TicketCategory category) async =>
      const Right(null);

  @override
  Future<Either<Failure, MessageEntity>> sendAdminReply(String id, String body) async => Right(
        MessageEntity(
          id: 'msg-2',
          ticketId: id,
          senderType: MessageSenderType.ADMIN,
          body: body,
          isAiGenerated: false,
          createdAt: DateTime.now(),
        ),
      );
}

void main() {
  late FakeAuthRepository authRepo;
  late FakeTicketRepository ticketRepo;
  late AuthCubit authCubit;
  late TicketListCubit ticketListCubit;

  setUp(() async {
    if (sl.isRegistered<TicketDetailCubit>()) {
      await sl.reset();
    }

    authRepo = FakeAuthRepository();
    ticketRepo = FakeTicketRepository();

    authCubit = AuthCubit(
      loginUseCase: LoginUsecase(authRepo),
      checkSessionStatusUseCase: CheckSessionStatusUseCase(authRepo),
      getCurrentAdminUseCase: GetCurrentAdminUseCase(authRepo),
      logoutUseCase: LogoutUseCase(authRepo),
    );

    ticketListCubit = TicketListCubit(
      getTicketsUseCase: GetTicketsUseCase(ticketRepo),
      getTicketStatsUseCase: GetTicketStatsUseCase(ticketRepo),
    );

    // Register TicketDetailCubit in service locator
    sl.registerFactory<TicketDetailCubit>(
      () => TicketDetailCubit(
        getTicketDetailUseCase: GetTicketDetailUseCase(ticketRepo),
        updateTicketStatusUseCase: UpdateTicketStatusUseCase(ticketRepo),
        updateTicketCategoryUseCase: UpdateTicketCategoryUseCase(ticketRepo),
        sendAdminReplyUseCase: SendAdminReplyUseCase(ticketRepo),
      ),
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildTestWidget({
    required Widget child,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<TicketListCubit>.value(value: ticketListCubit),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Responsive Master-Detail Layout Tests', () {
    testWidgets('Desktop view (>900px) displays 3-column layout: Sidebar, List, and Detail placeholder',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          child: const TicketDashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // AppSidebar exists
      expect(find.byType(AppSidebar), findsOneWidget);
      // TicketListPane exists
      expect(find.byType(TicketListPane), findsOneWidget);
      // TicketDetailPane exists
      expect(find.byType(TicketDetailPane), findsOneWidget);
      // Placeholder shows because no ticket is selected
      expect(find.text('No Ticket Selected'), findsOneWidget);
    });

    testWidgets('Desktop view (>900px) with selected ticket displays Detail pane with messages',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          child: const TicketDashboardPage(selectedTicketId: '1'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppSidebar), findsOneWidget);
      expect(find.byType(TicketListPane), findsOneWidget);
      expect(find.byType(TicketDetailPane), findsOneWidget);
      expect(find.text('Ticket #1'), findsOneWidget);
      expect(find.text('Hello, I was charged twice for renewal.'), findsOneWidget);
    });

    testWidgets('Mobile view (<900px) with no selection displays Ticket list with Drawer button',
        (tester) async {
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          child: const TicketDashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // In mobile view, AppSidebar is not directly visible on screen (it is in the drawer)
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
      expect(find.byType(TicketListPane), findsOneWidget);

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();

      // Now sidebar inside drawer is visible
      expect(find.byType(AppSidebar), findsOneWidget);
    });

    testWidgets('Mobile view (<900px) with selected ticket pushes to TicketDetailPage with back button',
        (tester) async {
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          child: const TicketDashboardPage(selectedTicketId: '1'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TicketDetailPage), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('Hello, I was charged twice for renewal.'), findsOneWidget);
    });

    testWidgets('Medium desktop/tablet view (840px - 1199px) displays compact Rail sidebar and Detail pane',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          child: const TicketDashboardPage(selectedTicketId: '1'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppSidebar), findsOneWidget);
      expect(find.byType(TicketListPane), findsOneWidget);
      expect(find.byType(TicketDetailPane), findsOneWidget);
      expect(find.text('Ticket #1'), findsOneWidget);
    });

    testWidgets('AdminReplyBar submits on Ctrl+Enter keyboard shortcut', (tester) async {
      String? submittedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminReplyBar(
              isSending: false,
              onSendReply: (text) async {
                submittedText = text;
                return true;
              },
            ),
          ),
        ),
      );

      final textFieldFinder = find.byType(TextField);
      await tester.enterText(textFieldFinder, 'Your refund has been processed.');
      await tester.pump();

      // Send Ctrl+Enter
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      expect(submittedText, equals('Your refund has been processed.'));
    });
  });
}
