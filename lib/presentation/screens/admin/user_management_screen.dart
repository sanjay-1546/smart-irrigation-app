import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/auth_provider.dart';
import '../../../application/providers/user_management_provider.dart';
import '../../../domain/entities/managed_user.dart';
import '../../../domain/entities/user.dart';
import '../../widgets/confirm_dialog.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().loadUsers();
    });
  }

  Future<void> _deleteUser(ManagedUser user) async {
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    if (currentUserId == user.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot delete your own account.')),
      );
      return;
    }
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete User',
      message: 'Delete ${user.name}? This cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    final provider = context.read<UserManagementProvider>();
    final ok = await provider.deleteUser(user.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'User deleted.' : (provider.errorMessage ?? 'Failed to delete user.'))),
    );
  }

  Future<void> _openEditDialog(ManagedUser user) async {
    final provider = context.read<UserManagementProvider>();
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    UserRole role = user.role;
    bool isActive = user.isActive;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text('Edit ${user.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<UserRole>(
                      initialValue: role,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: UserRole.values
                          .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setDialogState(() => role = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
                      value: isActive,
                      onChanged: (value) => setDialogState(() => isActive = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true || !mounted) return;
    final ok = await provider.updateUser(
      id: user.id,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      role: role,
      isActive: isActive,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'User updated.' : (provider.errorMessage ?? 'Failed to update user.'))),
    );
  }

  Future<void> _openCreateDialog() async {
    final provider = context.read<UserManagementProvider>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    UserRole role = UserRole.farmer;

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Create User'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<UserRole>(
                      initialValue: role,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: UserRole.values
                          .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setDialogState(() => role = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    if (created != true || !mounted) return;
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, email and password are required.')),
      );
      return;
    }
    final ok = await provider.registerUser(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      role: role,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'User created.' : (provider.errorMessage ?? 'Failed to create user.'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserManagementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_outlined),
            tooltip: 'Create user',
            onPressed: _openCreateDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading && provider.users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null && provider.users.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(provider.errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => provider.loadUsers(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : provider.users.isEmpty
                  ? const Center(child: Text('No users found.'))
                  : RefreshIndicator(
                      onRefresh: provider.loadUsers,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.users.length,
                        itemBuilder: (context, index) {
                          final user = provider.users[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: user.isActive
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : Theme.of(context).colorScheme.errorContainer,
                                child: Icon(
                                  user.isActive ? Icons.person_outline : Icons.person_off_outlined,
                                ),
                              ),
                              title: Text(user.name),
                              subtitle: Text(user.email),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Chip(
                                    label: Text(user.role.label),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => _openEditDialog(user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _deleteUser(user),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
