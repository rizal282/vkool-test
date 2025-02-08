import 'package:ecommerce_vkool/blocs/auth/login/login_event.dart';
import 'package:ecommerce_vkool/blocs/auth/login/login_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  LoginBloc() : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(LoginLoading());

      try {
        UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        User? user = userCredential.user;

        if (user != null) {
          // Mengirim state sukses dan membawa data email dan UID
          emit(LoginSuccess(fullname: user.displayName ?? '-', email: user.email ?? '', uid: user.uid));
        } else {
          emit(LoginFailure(error: 'User not found.'));
        }

      } catch (e) {
        emit(LoginFailure(error: e.toString()));
      }
    });
  }
}