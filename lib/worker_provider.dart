import 'package:flutter/foundation.dart';
import 'worker.dart';

class WorkerProvider extends ChangeNotifier {
  Worker? _worker;

  Worker? get worker => _worker;

  void setWorker(Worker worker) {
    _worker = worker;
    notifyListeners();
  }

  void clearWorker() {
    _worker = null;
    notifyListeners();
  }
}
