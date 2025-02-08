import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String fullname;
  final String email;
  final String uid;

  LoginSuccess({ required this.fullname, required this.email, required this.uid});

  @override
  List<Object?> get props => [fullname, email, uid];
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});

  @override
  List<Object?> get props => [error];
}