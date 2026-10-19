import 'package:flutter/material.dart';
import 'package:seqotia/widgets/glass_widgets.dart'; // adjust path based on this file's actual location

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0F1A14),
                  const Color(0xFF1A2F23).withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassContainer(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Welcome back to Seqotia',
                            style: TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF2ECC71),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    GlassCard(
                      title: 'Total Users',
                      value: '1,284',
                      icon: Icons.people_rounded,
                      iconColor: const Color(0xFF2ECC71),
                      onTap: () => Navigator.pushNamed(context, '/users'),
                    ),
                    const GlassCard(
                      title: 'Revenue',
                      value: '\$333,333',
                      icon: Icons.trending_up_rounded,
                      iconColor: Color(0xFF3498DB),
                    ),
                    const GlassCard(
                      title: 'Documents',
                      value: '856',
                      icon: Icons.description_rounded,
                      iconColor: Color(0xFFE74C3C),
                    ),
                    const GlassCard(
                      title: 'Processing',
                      value: '42',
                      icon: Icons.sync_rounded,
                      iconColor: Color(0xFFF39C12),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 12),
                GlassContainer(
                  height: 200,
                  borderRadius: BorderRadius.circular(16),
                  child: ListView.builder(
                    itemCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final activities = <(String, String, IconData)>[
                        ('Document Processed', 'report_2024.pdf', Icons.check_circle),
                        ('New User Added', 'john.doe@company.com', Icons.person_add),
                        ('System Update', 'v2.1.0 deployed', Icons.update),
                      ];
                      final (title, subtitle, icon) = activities[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(icon, color: const Color(0xFF2ECC71), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GlassButton(
                      label: 'Analytics',
                      icon: Icons.bar_chart_rounded,
                      onPressed: () => Navigator.pushNamed(context, '/analytics'),
                    ),
                    GlassButton(
                      label: 'Settings',
                      icon: Icons.settings_rounded,
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}