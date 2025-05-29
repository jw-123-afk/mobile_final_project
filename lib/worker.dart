class Worker {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String address;

  Worker({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: int.parse(json['id'].toString()),
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}
