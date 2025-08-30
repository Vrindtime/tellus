class EmployeeModel {
  String? id;
  String userId;
  String organizationId;
  String paymentType; // Fixed, Per Hour, Per Work
  double? fixedSalary;
  double? hourlyRate;
  String status; // Active, Left
  DateTime? joinedDate;

  EmployeeModel({
    this.id,
    required this.userId,
    required this.organizationId,
    required this.paymentType,
    this.fixedSalary,
    this.hourlyRate,
    required this.status,
    this.joinedDate,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'organizationId': organizationId,
        'paymentType': paymentType,
        'fixedSalary': fixedSalary,
        'hourlyRate': hourlyRate,
        'status': status,
        'joinedDate': joinedDate?.toIso8601String(),
      };

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
        id: json['\$id'],
        userId: json['userId'],
        organizationId: json['organizationId'],
        paymentType: json['paymentType'],
        fixedSalary: (json['fixedSalary'] as num?)?.toDouble(),
        hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
        status: json['status'],
        joinedDate: json['joinedDate'] != null ? DateTime.parse(json['joinedDate']) : null,
      );
}
