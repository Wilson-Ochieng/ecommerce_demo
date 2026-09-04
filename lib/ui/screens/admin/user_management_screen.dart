import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_app/data/models/user_model.dart';
import 'package:test_app/ui/screens/viewmodels/auth_startup_viewmodel.dart';
import 'package:test_app/ui/screens/viewmodels/user_management_viewmodel.dart';

class UserManagementScreen extends StatelessWidget {
  static const routeName = '/user-management';

  const UserManagementScreen({super.key});

  // ============================================================
  // CHANGE USER ROLE
  // ============================================================

  Future<void> _changeRole(
    BuildContext context,
    UserModel user,
    String newRole,
  ) async {
    final roleName = newRole == 'admin' ? 'Administrator' : 'Customer';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(newRole == 'admin' ? 'Promote User' : 'Change User Role'),
          content: Text(
            'Are you sure you want to change '
            '${user.name.isEmpty ? user.email : user.name} '
            'to $roleName?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(newRole == 'admin' ? 'Make Admin' : 'Make Customer'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final viewModel = context.read<UserManagementViewModel>();

    final success = await viewModel.changeRole(uid: user.uid, role: newRole);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${user.name.isEmpty ? user.email : user.name} is now a $roleName.'
              : viewModel.errorMessage ?? 'Failed to change user role.',
        ),
      ),
    );
  }

  // ============================================================
  // DELETE USER PROFILE
  // ============================================================

  Future<void> _deleteUser(BuildContext context, UserModel user) async {
    final displayName = user.name.isEmpty ? user.email : user.name;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: Colors.red,
          ),
          title: const Text('Delete User Profile'),
          content: Text(
            'Are you sure you want to delete the Firestore '
            'profile for "$displayName"?\n\n'
            'This operation removes the user profile from '
            'Firestore. It does not delete the Firebase '
            'Authentication account.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete Profile'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final viewModel = context.read<UserManagementViewModel>();

    final success = await viewModel.deleteUser(user.uid);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'User profile deleted successfully.'
              : viewModel.errorMessage ?? 'Failed to delete user profile.',
        ),
      ),
    );
  }

  // ============================================================
  // USER ROLE BADGE
  // ============================================================

  Widget _roleBadge(BuildContext context, UserModel user) {
    final isAdmin = user.role == 'admin';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAdmin
            ? Colors.orange.withValues(alpha: 0.12)
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin
                ? Icons.admin_panel_settings_outlined
                : Icons.person_outline,
            size: 16,
            color: isAdmin
                ? Colors.orange
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 5),
          Text(
            isAdmin ? 'Admin' : 'Customer',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isAdmin
                  ? Colors.orange
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VERIFICATION STATUS
  // ============================================================

  Widget _verificationStatus(BuildContext context, UserModel user) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _verificationChip(
          context: context,
          icon: Icons.email_outlined,
          label: user.emailVerified ? 'Email verified' : 'Email not verified',
          verified: user.emailVerified,
        ),
        _verificationChip(
          context: context,
          icon: Icons.phone_outlined,
          label: user.phoneVerified ? 'Phone verified' : 'Phone not verified',
          verified: user.phoneVerified,
        ),
      ],
    );
  }

  Widget _verificationChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool verified,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: verified
            ? Colors.green.withValues(alpha: 0.10)
            : Colors.grey.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.check_circle_outline : icon,
            size: 14,
            color: verified ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  // ============================================================
  // USER ACTION MENU
  // ============================================================

  Widget _userActions({
    required BuildContext context,
    required UserModel user,
    required UserModel? currentUser,
  }) {
    final isCurrentUser = currentUser?.uid == user.uid;

    final isAdmin = user.role == 'admin';

    return PopupMenuButton<String>(
      tooltip: 'User actions',
      onSelected: (value) {
        if (value == 'make_admin') {
          _changeRole(context, user, 'admin');
        }

        if (value == 'make_customer') {
          _changeRole(context, user, 'customer');
        }

        if (value == 'delete') {
          _deleteUser(context, user);
        }
      },
      itemBuilder: (context) {
        return [
          if (!isCurrentUser && !isAdmin)
            const PopupMenuItem<String>(
              value: 'make_admin',
              child: ListTile(
                leading: Icon(Icons.admin_panel_settings_outlined),
                title: Text('Make Admin'),
                contentPadding: EdgeInsets.zero,
              ),
            ),

          if (!isCurrentUser && isAdmin)
            const PopupMenuItem<String>(
              value: 'make_customer',
              child: ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('Make Customer'),
                contentPadding: EdgeInsets.zero,
              ),
            ),

          if (!isCurrentUser) const PopupMenuDivider(),

          if (!isCurrentUser)
            const PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  'Delete Profile',
                  style: TextStyle(color: Colors.red),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),

          if (isCurrentUser)
            const PopupMenuItem<String>(
              enabled: false,
              child: ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('Your account'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
        ];
      },
    );
  }

  // ============================================================
  // USER CARD
  // ============================================================

  Widget _userCard({
    required BuildContext context,
    required UserModel user,
    required UserModel? currentUser,
  }) {
    final isCurrentUser = currentUser?.uid == user.uid;

    final displayName = user.name.trim().isEmpty ? 'No name' : user.name.trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------
                // AVATAR
                // ------------------------------------------------
                CircleAvatar(
                  radius: 25,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // ------------------------------------------------
                // USER DETAILS
                // ------------------------------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),

                          if (isCurrentUser) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'YOU',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      if (user.phoneNumber.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.phoneNumber,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),

                // ------------------------------------------------
                // ACTIONS
                // ------------------------------------------------
                _userActions(
                  context: context,
                  user: user,
                  currentUser: currentUser,
                ),
              ],
            ),

            const SizedBox(height: 14),

            const Divider(),

            const SizedBox(height: 10),

            // ----------------------------------------------------
            // ROLE + VERIFICATION
            // ----------------------------------------------------
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 10,
              spacing: 16,
              children: [
                _roleBadge(context, user),

                _verificationStatus(context, user),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 70,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 16),

              Text(
                'No users found',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Registered users will appear here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final userManagementViewModel = context.watch<UserManagementViewModel>();

    final authStartupViewModel = context.watch<AuthStartupViewModel>();

    final currentUser = authStartupViewModel.user;

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),

      body: SafeArea(
        child: StreamBuilder<List<UserModel>>(
          stream: userManagementViewModel.users,
          builder: (context, snapshot) {
            // ==================================================
            // LOADING
            // ==================================================

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ==================================================
            // ERROR
            // ==================================================

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60),

                      const SizedBox(height: 16),

                      Text(
                        'Unable to load users.',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ==================================================
            // USERS
            // ==================================================

            final users = snapshot.data ?? [];

            if (users.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: _emptyState(context),
              );
            }

            // ==================================================
            // RESPONSIVE CONTENT
            // ==================================================

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;

                return SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? 24 : 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ------------------------------------
                          // HEADER
                          // ------------------------------------
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Users',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      '${users.length} registered user${users.length == 1 ? '' : 's'}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),

                              // --------------------------------
                              // LOADING INDICATOR
                              // --------------------------------
                              if (userManagementViewModel.isLoading)
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ------------------------------------
                          // INFORMATION CARD
                          // ------------------------------------
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Text(
                                      'Administrators can change '
                                      'user roles. Your own account '
                                      'cannot be demoted or deleted '
                                      'from this screen.',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ------------------------------------
                          // USER LIST
                          // ------------------------------------
                          ...users.map(
                            (user) => _userCard(
                              context: context,
                              user: user,
                              currentUser: currentUser,
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
