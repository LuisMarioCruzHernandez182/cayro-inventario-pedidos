import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/stats_entity.dart';
import '../../domain/usecases/get_current_month_stats_usecase.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object> get props => [];
}

class LoadCurrentMonthStats extends StatsEvent {}

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {}

class StatsLoading extends StatsState {}

class StatsLoaded extends StatsState {
  final StatsEntity stats;

  const StatsLoaded({required this.stats});

  @override
  List<Object> get props => [stats];
}

class StatsError extends StatsState {
  final String message;

  const StatsError({required this.message});

  @override
  List<Object> get props => [message];
}

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final GetCurrentMonthStatsUseCase getCurrentMonthStatsUseCase;

  StatsBloc({required this.getCurrentMonthStatsUseCase})
    : super(StatsInitial()) {
    on<LoadCurrentMonthStats>(_onLoadCurrentMonthStats);
  }

  Future<void> _onLoadCurrentMonthStats(
    LoadCurrentMonthStats event,
    Emitter<StatsState> emit,
  ) async {
    emit(StatsLoading());

    try {
      final result = await getCurrentMonthStatsUseCase();

      result.fold(
        (failure) {
          emit(StatsError(message: failure.message));
        },
        (stats) {
          emit(StatsLoaded(stats: stats));
        },
      );
    } catch (e) {
      emit(StatsError(message: 'Error inesperado al cargar estadísticas'));
    }
  }
}
