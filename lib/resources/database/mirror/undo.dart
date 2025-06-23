class Undo {
  final String description;
  final List<Function> _functions = [];

  Undo({required this.description});

  // Adds a new undo function to the list
  void addFunction(Function undoFunction) {
    _functions.add(undoFunction);
  }

  // Calls all stored undo functions in reverse order (undo last added first)
  void executeUndo() {
    for (Function function in _functions.reversed) {
      function();
    }
  }
}
