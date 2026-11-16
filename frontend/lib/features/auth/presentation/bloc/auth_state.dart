import '../../domain/entities/admin.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final Admin admin;
  const Authenticated(this.admin);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Authenticated && runtimeType == other.runtimeType && admin == other.admin;

  @override
  int get hashCode => admin.hashCode;
}

class Unauthenticated extends AuthState {
  final String? message;
  const Unauthenticated({this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unauthenticated && runtimeType == other.runtimeType && message == other.message;

  @override
  int get hashCode => message.hashCode;
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthFailure && runtimeType == other.runtimeType && message == other.message;

  @override
  int get hashCode => message.hashCode;
}
