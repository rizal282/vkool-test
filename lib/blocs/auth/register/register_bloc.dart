import 'package:ecommerce_vkool/blocs/auth/register/register_event.dart';
import 'package:ecommerce_vkool/blocs/auth/register/register_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterButtonPressed>((event, emit) async {
      emit(RegisterLoading());
      try {
        // Menggunakan Firebase untuk registrasi user
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(RegisterSuccess());
      } catch (e) {
        emit(RegisterFailure(error: e.toString()));
      }
    });
  }

  // @override
  // Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
  //   if (event is RegisterButtonPressed) {
  //     yield RegisterLoading();

  //     try {
  //       UserCredential userCredential =
  //           await _firebaseAuth.createUserWithEmailAndPassword(
  //               email: event.email, password: event.password);

  //       // Get user data from credential
  //       User? user = userCredential.user;
  //       if (user != null) {
  //         await user.updateDisplayName(event.fullName);
  //       }

  //       yield RegisterSuccess();
  //     } on FirebaseAuthException catch (e) {
  //       yield RegisterFailure(error: e.message ?? "An error occured");
  //     }
  //   }
  // }
}
