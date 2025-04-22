// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'bottom_navigation_cubit.dart';

class BottomNavigationState {
  int index;
  BottomNavigationState({
    required this.index,
  });

  BottomNavigationState copyWith({
    int? index,
  }) {
    return BottomNavigationState(
      index: index ?? this.index,
    );
  }
}
