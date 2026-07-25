import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin_provider.dart';

class ScreenAdminDashboard extends StatefulWidget {
  const ScreenAdminDashboard({super.key});

  @override
  State<ScreenAdminDashboard> createState() => _ScreenAdminDashboardState();
}

class _ScreenAdminDashboardState extends State<ScreenAdminDashboard> {
  String _selectedMenu = 'Manage Staff';

  @override
  void initState() {
    super.initState();
    // Fetch staff list when the dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchStaff();
    });
  }

  // ==========================================
  // BPMN WORKFLOW DIALOGS
  // ==========================================

  // Process: Add & Edit Tourism/PESO Staff Form
  void _showStaffForm({Map<String, dynamic>? existingStaff}) {
    final nameCtrl = TextEditingController(text: existingStaff?['name'] ?? '');
    final emailCtrl = TextEditingController(
      text: existingStaff?['email'] ?? '',
    );

    // 1. Get the role from the database
    String role = existingStaff?['role'] ?? 'Job Poster';

    // 2. Validate the role! If it's an old legacy role like 'Staff' or 'peso_staff',
    // force it to default to 'Job Poster' so the dropdown doesn't crash.
    const validRoles = ['Job Poster', 'Job Matcher', 'Admin'];
    if (!validRoles.contains(role)) {
      role = 'Job Poster';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          existingStaff == null ? "Add New Staff" : "Edit Staff Details",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Update this in _showStaffForm
              DropdownButtonFormField<String>(
                value: role, // Now guaranteed to be one of the items below
                decoration: const InputDecoration(
                  labelText: "Assign Role",
                  border: OutlineInputBorder(),
                ),
                items: validRoles
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) => role = val!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<AdminProvider>();

              if (existingStaff == null) {
                // ADD PROCESS: Save and system generates temporary password
                final result = await provider.addStaff(
                  nameCtrl.text,
                  emailCtrl.text,
                  role,
                );
                if (result.containsKey('tempPassword') && mounted) {
                  _showAlert(
                    context,
                    "Account Created",
                    "Staff account successfully created.\n\nTemporary Password: ${result['tempPassword']}\n\n(System simulation: Login credentials sent via email).",
                  );
                }
              } else {
                // EDIT PROCESS: Update existing record
                final result = await provider.updateStaff(
                  existingStaff['staff_id'],
                  nameCtrl.text,
                  emailCtrl.text,
                  role,
                );
                if (mounted && result.containsKey('message')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  // Process: Reset Staff Password
  Future<void> _confirmReset(Map<String, dynamic> staff) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reset Password?"),
        content: Text(
          "Generate a new temporary password for ${staff['name']}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Confirm Reset"),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final res = await context.read<AdminProvider>().resetPassword(
        staff['staff_id'],
      );
      if (res.containsKey('tempPassword')) {
        _showAlert(
          context,
          "Password Reset Successful",
          "New temporary password for ${staff['name']} is:\n\n${res['tempPassword']}\n\n(System simulation: Login credentials sent via email).",
        );
      }
    }
  }

  // Process: Delete Staff Account
  Future<void> _confirmDelete(Map<String, dynamic> staff) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Account?"),
        content: Text(
          "Are you sure you want to permanently remove the record for ${staff['name']}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Confirm Removal"),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final res = await context.read<AdminProvider>().deleteStaff(
        staff['staff_id'],
      );
      if (res.containsKey('error')) {
        _showAlert(context, "Action Failed", res['error']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Staff Record Deleted"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAlert(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(msg),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UI LAYOUT BUILDERS
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // 1. LEFT SIDEBAR
          Container(
            width: 260,
            color: const Color(0xFF1E293B),
            child: Column(
              children: [
                _buildSidebarHeader(),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildSidebarItem(Icons.grid_view_rounded, 'Dashboard'),
                      _buildSidebarItem(
                        Icons.manage_accounts_rounded,
                        'Manage Staff',
                        badgeCount: context
                            .watch<AdminProvider>()
                            .staffList
                            .length,
                      ),
                      _buildSidebarItem(
                        Icons.people_alt_rounded,
                        'Job Seekers',
                      ),
                      _buildSidebarItem(Icons.business_rounded, 'Employers'),
                      _buildSidebarItem(
                        Icons.bar_chart_rounded,
                        'Reports & Analytics',
                      ),
                    ],
                  ),
                ),
                _buildSidebarFooter(),
              ],
            ),
          ),

          // 2. MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPageTitleRow(),
                        const SizedBox(height: 24),
                        _buildStaffTableCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: Color(0xFF1E293B),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PESO Naga',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Admin Portal',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, {int? badgeCount}) {
    final isSelected = _selectedMenu == title;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF334155) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: () => setState(() => _selectedMenu = title),
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing: badgeCount != null && badgeCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Column(
      children: [
        const Divider(color: Color(0xFF334155), height: 1),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF2563EB),
                child: Text(
                  'AD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Administrator',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopHeader() {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 350,
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search personnel...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: Color(0xFF64748B),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF1E3A8A),
                child: Text(
                  'AD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Staff Management',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Manage PESO personnel accounts and system access',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showStaffForm(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add New Staff'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaffTableCard() {
    final provider = context.watch<AdminProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Table Headers
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'NAME',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'EMAIL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'ROLE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'ACTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Data Rows
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.staffList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  "No staff records found.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...provider.staffList.map((staff) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              staff['role'] == 'Admin'
                                  ? Icons.shield
                                  : Icons.badge,
                              color: const Color(0xFF3B82F6),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // SAFE NULL HANDLING
                          Text(
                            staff['name']?.toString() ?? 'N/A',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SAFE NULL HANDLING
                    Expanded(
                      flex: 2,
                      child: Text(
                        staff['email']?.toString() ?? 'N/A',
                        style: const TextStyle(color: Color(0xFF334155)),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: UnconstrainedBox(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          // SAFE NULL HANDLING
                          child: Text(
                            staff['role']?.toString() ?? 'Staff',
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: UnconstrainedBox(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Color(0xFF64748B),
                            ),
                            tooltip: 'Edit',
                            onPressed: () =>
                                _showStaffForm(existingStaff: staff),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.lock_reset_rounded,
                              size: 18,
                              color: Colors.orange,
                            ),
                            tooltip: 'Reset Password',
                            onPressed: () => _confirmReset(staff),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: Color(0xFFEF4444),
                            ),
                            tooltip: 'Delete',
                            onPressed: () => _confirmDelete(staff),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
