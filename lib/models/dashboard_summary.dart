class DashboardSummary {
  final String userName;
  final int totalUsers;
  final int documents;
  final int aiJobs;
  final int completedJobs;
  final List<DashboardActivity> activities;

  const DashboardSummary({
    required this.userName,
    required this.totalUsers,
    required this.documents,
    required this.aiJobs,
    required this.completedJobs,
    required this.activities,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      userName: json['user_name'] as String? ?? 'Seqotia User',
      totalUsers: json['total_users'] as int? ?? 0,
      documents: json['documents'] as int? ?? 0,
      aiJobs: json['ai_jobs'] as int? ?? 0,
      completedJobs: json['completed_jobs'] as int? ?? 0,
      activities: (json['activities'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(DashboardActivity.fromJson)
          .toList(),
    );
  }
}

class DashboardActivity {
  final String title;
  final String subtitle;
  final String kind;

  const DashboardActivity({
    required this.title,
    required this.subtitle,
    required this.kind,
  });

  factory DashboardActivity.fromJson(Map<String, dynamic> json) {
    return DashboardActivity(
      title: json['title'] as String? ?? 'Activity',
      subtitle: json['subtitle'] as String? ?? '',
      kind: json['kind'] as String? ?? 'info',
    );
  }
}
