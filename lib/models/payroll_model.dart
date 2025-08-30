class Payroll {
  String? id;
  String employeeId;
  String organizationId;
  DateTime salaryDate;
  double grossSalary;
  double deductions;
  double netSalary;
  double amountPaid;
  String paymentStatus; // Pending, Paid, Partial
  String? notes;

  Payroll({
    this.id,
    required this.employeeId,
    required this.organizationId,
    required this.salaryDate,
    required this.grossSalary,
    required this.deductions,
    required this.netSalary,
    required this.amountPaid,
    required this.paymentStatus,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'salaryDate': salaryDate.toIso8601String(),
    'grossSalary': grossSalary,
    'deductions': deductions,
    'organizationId': organizationId, // Added organizationId to JSON
    'netSalary': netSalary,
    'amountPaid': amountPaid,
    'paymentStatus': paymentStatus,
    'notes': notes,
  };

  factory Payroll.fromJson(Map<String, dynamic> json) => Payroll(
    id: json['\$id'],
    employeeId:
        json['employeeId'] is String
            ? json['employeeId']
            : (json['employeeId']?['\$id'] ?? ''), // unwrap relation
    salaryDate: DateTime.parse(json['salaryDate']),
    grossSalary: (json['grossSalary'] as num).toDouble(),
    deductions: (json['deductions'] as num).toDouble(),
    organizationId: json['organizationId'] ?? '',
    netSalary: (json['netSalary'] as num).toDouble(),
    amountPaid: (json['amountPaid'] as num).toDouble(),
    paymentStatus: json['paymentStatus'],
    notes: json['notes'],
  );
}
