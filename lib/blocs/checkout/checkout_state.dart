import 'package:equatable/equatable.dart';

abstract class CheckoutState extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {}

class CheckoutFailure extends CheckoutState {
  final String message;
  CheckoutFailure({required this.message});

  @override
  List<Object> get props => [message];
}