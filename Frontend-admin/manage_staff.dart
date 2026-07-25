import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin_provider.dart';

class ScreenManageStaff extends StatefulWidget {
  const ScreenManageStaff({super.key});

  @override
  State<ScreenManageStaff> createState() => _ScreenManageStaffState();
}

class _ScreenManageStaffState extends State<ScreenManageStaff> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchStaff();
    });
  }

  void _showStaffForm({Map<String, dynamic>? existingStaff}) {
    final nameCtrl = TextEditingController(text: existingStaff?['name'] ?? '');
    final emailCtrl = TextEditingController(text: existingStaff?['email'] ?? '');
    String role = existingStaff?['role'] ?? 'Staff';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingStaff == null ? "Add New Staff" : "Edit Staff Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full Name")),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email Address")),
            DropdownButtonFormField<String>(
              value: role,
              items: ['Staff', 'Admin'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) => role = val!,
              decoration: const InputDecoration(labelText: "Assign Role"),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<AdminProvider>();
              Map<String, dynamic> result;
              
              if (existingStaff == null) {
                result = await provider.addStaff(nameCtrl.text, emailCtrl.text, role);
                if (result.containsKey('tempPassword') && mounted) {
                  _showAlert(context, "Success", "Account created!\n\nTemporary Password: ${result['tempPassword']}\n\n(System simulation: This has been emailed to the staff member).");
                }
              } else {
                result = await provider.updateStaff(existingStaff['staff_id'], nameCtrl.text, emailCtrl.text, role);
                if (mounted && result.containsKey('message')) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
                }
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _showAlert(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage PESO Staff"),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStaffForm(),
        icon: const Icon(Icons.person_add),
        label: const Text("Add Staff"),
        backgroundColor: Colors.blue.shade900,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.staffList.length,
              itemBuilder: (context, index) {
                final staff = provider.staffList[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(staff['role'] == 'Admin' ? Icons.shield : Icons.badge, color: Colors.blue.shade900),
                    ),
                    title: Text(staff['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${staff['role']} | ${staff['email']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          tooltip: "Edit Staff",
                          onPressed: () => _showStaffForm(existingStaff: staff),
                        ),
                        IconButton(
                          icon: const Icon(Icons.lock_reset, color: Colors.orange),
                          tooltip: "Reset Password",
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Reset Password?"),
                                content: Text("Generate a new temporary password for ${staff['name']}?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                                  ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Reset")),
                                ],
                              ),
                            );
                            if (confirm == true && mounted) {
                              final res = await provider.resetPassword(staff['staff_id']);
                              if (res.containsKey('tempPassword')) {
                                _showAlert(context, "Password Reset", "New temporary password for ${staff['name']} is:\n\n${res['tempPassword']}\n\n(System simulation: Email sent).");
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: "Delete Account",
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Delete Account?"),
                                content: Text("Are you sure you want to permanently remove ${staff['name']}?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () => Navigator.pop(ctx, true), 
                                    child: const Text("Delete", style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && mounted) {
                              final res = await provider.deleteStaff(staff['staff_id']);
                              if (res.containsKey('error')) {
                                _showAlert(context, "Action Failed", res['error']);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}