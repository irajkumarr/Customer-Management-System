import 'package:equatable/equatable.dart';
import '../../data/models/ticket_enums.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/entities/ticket_stats_entity.dart';

enum TicketListStatus { initial, loading, refreshing, success, failure }

class TicketListState extends Equatable {
  final TicketListStatus status;
  final List<TicketEntity> tickets;
  final TicketStatsEntity? stats;
  final TicketStatus? selectedStatus;
  final TicketCategory? selectedCategory;
  final String searchQuery;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final String? errorMessage;

  const TicketListState({
    this.status = TicketListStatus.initial,
    this.tickets = const [],
    this.stats,
    this.selectedStatus,
    this.selectedCategory,
    this.searchQuery = '',
    this.currentPage = 0,
    this.totalPages = 0,
    this.totalElements = 0,
    this.errorMessage,
  });

  bool get isLoading => status == TicketListStatus.loading;
  bool get isRefreshing => status == TicketListStatus.refreshing;
  bool get hasError => status == TicketListStatus.failure;
  bool get isEmpty => status == TicketListStatus.success && tickets.isEmpty;

  TicketListState copyWith({
    TicketListStatus? status,
    List<TicketEntity>? tickets,
    TicketStatsEntity? stats,
    TicketStatus? Function()? selectedStatus,
    TicketCategory? Function()? selectedCategory,
    String? searchQuery,
    int? currentPage,
    int? totalPages,
    int? totalElements,
    String? errorMessage,
  }) {
    return TicketListState(
      status: status ?? this.status,
      tickets: tickets ?? this.tickets,
      stats: stats ?? this.stats,
      selectedStatus: selectedStatus != null ? selectedStatus() : this.selectedStatus,
      selectedCategory: selectedCategory != null ? selectedCategory() : this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tickets,
        stats,
        selectedStatus,
        selectedCategory,
        searchQuery,
        currentPage,
        totalPages,
        totalElements,
        errorMessage,
      ];
}
