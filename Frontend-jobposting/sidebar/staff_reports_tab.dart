import 'package:flutter/material.dart';

class StaffReportsTab extends StatelessWidget {
  const StaffReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Reports & Analytics",
            style: TextStyle(color: Color(0xFF1E293B), fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            "View and export local employment statistics and charts",
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "Analytics Compilation Engine Ready",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Data maps will populate automatically as placement states change.",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}