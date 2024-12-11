class PostModel {
  final int id;
  final String title;
  final String body;
  bool isRead;
  int? estimatedReadTime;
  int? remainingTime;

  PostModel({
    required this.id,
    required this.title,
    required this.body,
    this.isRead = false,
    this.estimatedReadTime,
    this.remainingTime,
  });

  PostModel copyWith({
    int? id,
    String? title,
    String? body,
    bool? isRead,
    int? estimatedReadTime,
    int? remainingTime,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      estimatedReadTime: estimatedReadTime ?? this.estimatedReadTime,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      estimatedReadTime: _generateRandomReadTime(),
    );
  }

  static int _generateRandomReadTime() {
    return [10, 20, 25][DateTime.now().millisecond % 3];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'isRead': isRead,
        'estimatedReadTime': estimatedReadTime,
      };
}
