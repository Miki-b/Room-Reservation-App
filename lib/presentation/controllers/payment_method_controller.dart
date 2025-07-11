import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/payment_method_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodState {
  final List<PaymentMethod> methods;
  final bool loading;
  final String? error;
  PaymentMethodState(
      {this.methods = const [], this.loading = false, this.error});
  PaymentMethodState copyWith(
          {List<PaymentMethod>? methods, bool? loading, String? error}) =>
      PaymentMethodState(
        methods: methods ?? this.methods,
        loading: loading ?? this.loading,
        error: error,
      );
}

class PaymentMethodController extends StateNotifier<PaymentMethodState> {
  PaymentMethodController() : super(PaymentMethodState());

  Future<void> fetch() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('payment_methods').get();
      final methods = snapshot.docs
          .map((doc) => PaymentMethod.fromMap(doc.data()))
          .toList();
      state = state.copyWith(methods: methods, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}

final paymentMethodControllerProvider =
    StateNotifierProvider<PaymentMethodController, PaymentMethodState>(
        (ref) => PaymentMethodController());
