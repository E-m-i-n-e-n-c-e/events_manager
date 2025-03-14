import 'package:events_manager/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:events_manager/providers/stream_providers.dart';
import 'package:events_manager/utils/firedata.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:events_manager/screens/profile/edit_profile_form.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isHeaderCollapsed = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 140 && !_isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = true);
    } else if (_scrollController.offset <= 140 && _isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appUserAsync = ref.watch(currentUserProvider);
    final clubsAsync = ref.watch(clubsStreamProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _isHeaderCollapsed ? const Color(0xFF06222F) : Colors.transparent,
        elevation: _isHeaderCollapsed ? 4 : 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFAEE7FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isHeaderCollapsed
            ? appUserAsync.when(
                data: (user) => user != null ? Text(
                  user.name,
                  style: const TextStyle(
                    color: Color(0xFFAEE7FF),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ) : const SizedBox(),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              )
            : null,
        actions: [
          appUserAsync.when(
            data: (user) => user != null ? IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFFAEE7FF)),
              onPressed: () async {
                final updatedUser = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileForm(user: user),
                  ),
                );
                if (updatedUser != null) {
                  ref.invalidate(currentUserProvider);
                }
              },
            ) : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF07181F), Color(0xFF000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: appUserAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAEE7FF)),
          )),
          error: (error, stack) => Center(
            child: Text(
              'Error loading profile: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          data: (appUser) {
            if (appUser == null) {
              return const Center(
                child: Text(
                  'User profile not found',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
            children: [
                      // Header background with gradient overlay
                      Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: const Color(0xFF06222F),
                          image: DecorationImage(
                            image: NetworkImage(
                              appUser.backgroundImageUrl ?? appUser.photoURL ?? 'https://via.placeholder.com/400x200/0F2026/71C2E4?text=Profile',
                            ),
                            fit: BoxFit.cover,
                            opacity: 0.3,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF07181F).withValues(alpha:0.8),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Profile info overlay
                      Positioned(
                        bottom: 20,
                        left: 27,
                        right: 27,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Profile image
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF71C2E4),
                                      width: 2,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        appUser.photoURL ?? 'https://via.placeholder.com/150/0F2026/71C2E4?text=User',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Name and stats
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
              Text(
                                        appUser.name,
                style: const TextStyle(
                                          color: Color(0xFF61E7FF),
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          _buildMetricItem(
                                            FontAwesomeIcons.clock,
                                            'Since ${DateFormat('MMM yyyy').format(appUser.createdAt)}',
                                            '',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile details section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Profile Details'),
                        const SizedBox(height: 16),

                        // Profile details card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F2026),
                            borderRadius: BorderRadius.circular(17),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x40000000),
                                blurRadius: 5.1,
                                offset: Offset(0, 2),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildProfileDetailRow(
                                FontAwesomeIcons.solidEnvelope,
                                'Email',
                                appUser.email,
                              ),
                              const Divider(color: Color(0xFF17323D), height: 24),
                              _buildProfileDetailRow(
                                FontAwesomeIcons.idCard,
                                'Roll Number',
                                appUser.rollNumber ?? 'Not set',
                              ),
                              const Divider(color: Color(0xFF17323D), height: 24),
                              _buildProfileDetailRow(
                                FontAwesomeIcons.calendarDays,
                                'Member since',
                                DateFormat('MMM d, yyyy').format(appUser.createdAt),
                              ),
                              const Divider(color: Color(0xFF17323D), height: 24),
                              _buildProfileDetailRow(
                                FontAwesomeIcons.doorOpen,
                                'Last login',
                                DateFormat('MMM d, yyyy - h:mm a').format(appUser.lastLogin),
                              ),
                            ],
                          ),
                        ),

                        // Club admin section
                        clubsAsync.when(
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                          data: (clubs) {
                            final adminClubs = clubs.where(
                              (club) => club.adminEmails.contains(appUser.email)
                            ).toList();

                            if (adminClubs.isEmpty) return const SizedBox();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                _buildSectionHeader('Club Administration'),
                                const SizedBox(height: 16),

                                // Club admin card
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F2026),
                                    borderRadius: BorderRadius.circular(17),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x40000000),
                                        blurRadius: 5.1,
                                        offset: Offset(0, 2),
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'You are an admin for the following clubs:',
                                        style: TextStyle(
                                          color: Color(0xFFAEE7FF),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Club selection dropdown
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFF71C2E4).withValues(alpha:0.3)),
                                          color: const Color(0xFF17323D),
                                        ),
                                        child: DropdownButton<String?>(
                                          value: appUser.clubId ?? '',
                                          hint: const Text('Select active club',
                                            style: TextStyle(color: Color(0xFFAEE7FF)),
                                          ),
                                          dropdownColor: const Color(0xFF17323D),
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFAEE7FF)),
                                          items: [
                                            const DropdownMenuItem<String?>(
                                              value: '',
                                              child: Text(
                                                'None',
                                                style: TextStyle(color: Color(0xFFAEE7FF)),
                                              ),
                                            ),
                                            ...adminClubs.map((club) {
                                              return DropdownMenuItem(
                                                value: club.id,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                          image: NetworkImage(club.logoUrl),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      club.name,
                                                      style: const TextStyle(color: Color(0xFFAEE7FF)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ],
                                          onChanged: (String? newValue) async {
                                            try {
                                              await updateUserClubId(appUser.uid, newValue ?? '');
                                              setState(() {
                                                appUser.clubId = newValue;
                                              });
                                              ref.invalidate(currentUserProvider);
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).clearSnackBars();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    newValue == ''
                                                        ? 'Club admin role removed'
                                                        : 'Club admin role updated to ${adminClubs.firstWhere((club) => club.id == newValue).name}',
                                                  ),
                                                  backgroundColor: const Color(0xFF0E668A),
                                                ),
                                              );
                                            } catch (e) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Failed to update club: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 16),
                                      const Text(
                                        'As a club admin, you can create events and announcements for your club.',
                                        style: TextStyle(
                                          color: Color(0xFF83ACBD),
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // Logout button
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                onPressed: () async {
                  await AuthService().signOut();
                  invalidateAllProviders(ref);
                  if (!context.mounted) return;
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E668A),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.logout, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'LOGOUT',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFFAEE7FF),
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFFAEE7FF).withValues(alpha:0.7),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF17323D),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFAEE7FF),
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFFAEE7FF).withValues(alpha:0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFFAEE7FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
