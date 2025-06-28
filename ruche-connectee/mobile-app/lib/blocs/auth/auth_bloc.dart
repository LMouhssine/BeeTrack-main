import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ruche_connectee/services/auth_service.dart';

// Événements
abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  RegisterEvent({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}

class LogoutEvent extends AuthEvent {}

// États
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final String userId;

  AuthenticatedState({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;

  AuthErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        emit(AuthenticatedState(userId: user.uid));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final user = await _authService.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      if (user != null) {
        emit(AuthenticatedState(userId: user.uid));
      } else {
        emit(AuthErrorState(message: 'Échec de la connexion'));
      }
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final user = await _authService.registerWithEmailAndPassword(
        event.email,
        event.password,
        event.name,
      );
      if (user != null) {
        emit(AuthenticatedState(userId: user.uid));
      } else {
        emit(AuthErrorState(message: 'Échec de la création du compte'));
      }
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      await _authService.signOut();
      emit(UnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }
}
