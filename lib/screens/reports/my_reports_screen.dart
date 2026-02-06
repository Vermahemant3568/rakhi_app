import 'package:flutter/material.dart';
import 'package:rakhi_app/core/constants/app_colors.dart';
import 'package:rakhi_app/core/api/api_client.dart';
import 'package:rakhi_app/models/report.dart';
import 'package:rakhi_app/screens/reports/pdf_viewer_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  List<Report> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final response = await ApiClient.getReports();
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        setState(() {
          _reports = data.map((json) => Report.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.data['error']}')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reports: $e')),
      );
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'diet':
        return Icons.restaurant;
      case 'fitness':
        return Icons.fitness_center;
      case 'consultation':
        return Icons.medical_services;
      default:
        return Icons.description;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'diet':
        return Colors.green;
      case 'fitness':
        return Colors.orange;
      case 'consultation':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _reports.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No reports available', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getTypeColor(report.type),
                            child: Icon(_getTypeIcon(report.type), color: Colors.white),
                          ),
                          title: Text(report.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${report.type.toUpperCase()} • ${_formatDate(report.createdAt)}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PdfViewerScreen(report: report),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}