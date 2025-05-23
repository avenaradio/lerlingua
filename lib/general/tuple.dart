class Tuple3<T1, T2, T3> {
  final T1 first;
  final T2 second;
  final T3 third;

  Tuple3(this.first, this.second, this.third);

  @override
  String toString() {
    return 'Tuple3($first, $second, $third)';
  }
}
