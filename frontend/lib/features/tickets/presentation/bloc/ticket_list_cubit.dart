import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/ticket_enums.dart';
import '../../domain/usecases/get_ticket_stats_usecase.dart';
import '../../domain/usecases/get_tickets_usecase.dart';
import 'ticket_list_state.dart';

class TicketListCubit extends Cubit<TicketListState> {
  final GetTicketsUseCase getTicketsUseCase;
  final GetTicketStatsUseCase getTicketStatsUseCase;

  TicketListCubit({
    required this.getTicketsUseCase,
    required this.getTicketStatsUseCase,
  }) : super(const TicketListState());

  Future<void> loadInitialData() async {
    emit(state.copyWith(status: TicketListStatus.loading));
    await Future.wait([
      _fetchStats(),
      _fetchTickets(page: 0),
    ]);
  }

  /// Explicit Manual Refresh (pull-to-refresh or refresh button)
  Future<void> refresh() async {
    emit(state.copyWith(status: TicketListStatus.refreshing));
    await Future.wait([
      _fetchStats(),
      _fetchTickets(page: 0),
    ]);
  }

  Future<void> setStatusFilter(TicketStatus? status) async {
    if (state.selectedStatus == status) return;
    emit(state.copyWith(
      selectedStatus: () => status,
      currentPage: 0,
      status: TicketListStatus.loading,
    ));
    await _fetchTickets(page: 0);
  }

  Future<void> setCategoryFilter(TicketCategory? category) async {
    if (state.selectedCategory == category) return;
    emit(state.copyWith(
      selectedCategory: () => category,
      currentPage: 0,
      status: TicketListStatus.loading,
    ));
    await _fetchTickets(page: 0);
  }

  Future<void> setSearchQuery(String query) async {
    final trimmed = query.trim();
    if (state.searchQuery == trimmed) return;
    emit(state.copyWith(
      searchQuery: trimmed,
      currentPage: 0,
      status: TicketListStatus.loading,
    ));
    await _fetchTickets(page: 0);
  }

  Future<void> changePage(int page) async {
    if (page == state.currentPage || page < 0 || (state.totalPages > 0 && page >= state.totalPages)) {
      return;
    }
    emit(state.copyWith(
      currentPage: page,
      status: TicketListStatus.loading,
    ));
    await _fetchTickets(page: page);
  }

  Future<void> _fetchStats() async {
    final result = await getTicketStatsUseCase(const NoParams());
    result.fold(
      (failure) {
        // Retain existing stats if failure
      },
      (stats) {
        emit(state.copyWith(stats: stats));
      },
    );
  }

  Future<void> _fetchTickets({required int page}) async {
    final result = await getTicketsUseCase(
      GetTicketsParams(
        status: state.selectedStatus,
        category: state.selectedCategory,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        page: page,
        size: 20,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: TicketListStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (pageResponse) {
        emit(state.copyWith(
          status: TicketListStatus.success,
          tickets: pageResponse.content,
          currentPage: pageResponse.number,
          totalPages: pageResponse.totalPages,
          totalElements: pageResponse.totalElements,
          errorMessage: null,
        ));
      },
    );
  }
}
