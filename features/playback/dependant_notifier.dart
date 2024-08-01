import 'package:flutter/cupertino.dart';

class DependantValueNotifier<T> extends ValueNotifier<T> {
  DependantValueNotifier(T item) : super(item);

  List<VoidCallback> listeners = List.empty(growable: true);

  @override
  void addListener(VoidCallback listener) {
    listeners.add(listener);
    super.addListener(listener);
  }

  void addValueListener(ValueSetter<T> listener) {
    listeners.add(() => listener.call(value));
    super.addListener(listeners.last);
  }

  void removeAllListeners() {
    for (final listener in listeners) {
      removeListener(listener);
    }
    listeners.clear();
  }

  @override
  void dispose() {
    removeAllListeners();
    super.dispose();
  }
}
