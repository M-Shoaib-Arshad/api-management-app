import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ApiService _apiService = ApiService();
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _apiService.fetchUser(widget.userId);
  }

  void _reload() {
    setState(() {
      _userFuture = _apiService.fetchUser(widget.userId);
    });
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        centerTitle: true,
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingIndicator(message: 'Loading profile…');
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            final message = error is ApiException
                ? error.message
                : 'An unexpected error occurred.';
            return ErrorDisplay(message: message, onRetry: _reload);
          }

          final user = snapshot.data!;
          return _ProfileBody(user: user);
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final User user;

  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CachedNetworkImage(
            imageUrl: user.avatarUrl,
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: 60,
              backgroundImage: imageProvider,
            ),
            placeholder: (_, __) => const CircleAvatar(
              radius: 60,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            errorWidget: (_, __, ___) => CircleAvatar(
              radius: 60,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 60,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            user.name,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            '@${user.username}',
            style: textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Details card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email,
                  ),
                  const Divider(),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: user.phone,
                  ),
                  const Divider(),
                  _InfoRow(
                    icon: Icons.language_outlined,
                    label: 'Website',
                    value: user.website,
                  ),
                  const Divider(),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value:
                        '${user.address.street}, ${user.address.suite}\n${user.address.city} ${user.address.zipcode}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Company card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.business_outlined),
                      const SizedBox(width: 8),
                      Text('Company', style: textTheme.titleMedium),
                    ],
                  ),
                  const Divider(),
                  Text(
                    user.company.name,
                    style: textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"${user.company.catchPhrase}"',
                    style: textTheme.bodyMedium
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 4),
                  Text(user.company.bs, style: textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
