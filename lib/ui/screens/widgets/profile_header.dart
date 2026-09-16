import 'package:flutter/material.dart';
import 'package:test_app/data/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasImage = user.userImage != null && user.userImage!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage: hasImage ? NetworkImage(user.userImage!) : null,
            child: !hasImage
                ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary)
                : null,
          ),

          const SizedBox(height: 14),

          Text(
            user.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          Text(
            user.email,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),

          const SizedBox(height: 4),

          Text(
            user.phoneNumber,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
