import 'package:flutter/foundation.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String organizationId;
  final DateTime date;
  final String? bookingType;
  final String? partyName;
  final String? workLocation;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.organizationId,
    required this.date,
    this.bookingType,
    this.partyName,
    this.workLocation,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? json['\$id'] ?? UniqueKey().toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      organizationId: json['organizationId'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      bookingType: json['bookingType'],
      partyName: json['partyName'],
      workLocation: json['workLocation'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'organizationId': organizationId,
    'date': date.toIso8601String(),
    'bookingType': bookingType,
    'partyName': partyName,
    'workLocation': workLocation,
  };
}
