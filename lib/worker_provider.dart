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

  void updateWorker({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) {
    if (_worker != null) {
      _worker = Worker(
        id: _worker!.id,
        fullName: name,
        email: email,
        phone: phone,
        address: address,
      );
      notifyListeners();
    }
  }
}
