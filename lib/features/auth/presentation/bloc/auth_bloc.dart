import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String identifier;
  final String password;

  const LoginRequested({required this.identifier, required this.password});

  @override
  List<Object> get props => [identifier, password];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await loginUseCase(event.identifier, event.password);

      result.fold(
        (failure) {
          emit(AuthError(message: failure.message));
        },
        (user) {
          emit(AuthAuthenticated(user: user));
        },
      );
    } catch (e) {
      emit(AuthError(message: 'Error inesperado durante el login'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await logoutUseCase();

      result.fold(
        (failure) {
          emit(AuthError(message: failure.message));
        },
        (_) {
          emit(AuthUnauthenticated());
        },
      );
    } catch (e) {
      emit(AuthError(message: 'Error inesperado durante el logout'));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await getCurrentUserUseCase();

      result.fold(
        (failure) {
          if (failure.message.contains('Token inválido') ||
              failure.message.contains('Unauthorized') ||
              failure.message.contains('401') ||
              failure.message.contains('token') ||
              failure.message.contains('unauthorized')) {
            emit(AuthUnauthenticated());
          } else {
            emit(
              AuthError(
                message: 'Error verificando sesión: ${failure.message}',
              ),
            );
          }
        },
        (user) {
          emit(AuthAuthenticated(user: user));
        },
      );
    } catch (e) {
      emit(AuthError(message: 'Error inesperado verificando sesión'));
    }
  }
}
