import 'package:bloc/bloc.dart';

part 'bottom_navigation_state.dart';

class BottomNavigationCubit extends Cubit<BottomNavigationState> {
  BottomNavigationCubit() : super(BottomNavigationState(index: 0));

  Future<void> changeIndex(int index) async {
    emit(state.copyWith(index: index));
  }
}
