class Report {
  final int id;
  final String title;
  final String type; // 'diet', 'fitness', 'consultation'
  final String pdfUrl;
  final DateTime createdAt;
  
  Report({
    required this.id,
    required this.title,
    required this.type,
    required this.pdfUrl,
    required this.createdAt,
  });
  
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      title: json['title'] ?? 'Report',
      type: json['type'] ?? 'consultation',
      pdfUrl: json['pdf_url'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}