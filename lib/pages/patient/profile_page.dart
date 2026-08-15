import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/supabase_service.dart';
import '../../widgets/app_bottom_nav.dart';
import '../login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SupabaseService.getProfile();
    setState(() {
      profile = p;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        title: const Text('My Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Device status header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.devices, color: Colors.blue.shade700),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Device Status',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('Active · Device Synced',
                                      style: TextStyle(
                                          color: Colors.green, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.bluetooth, color: Colors.blue.shade400),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Personal Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Personal Information',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Edit'),
                            ),
                          ],
                        ),
                        const Divider(),
                        _infoRow(Icons.person_outline, 'Full Name', profile?.fullName ?? ''),
                        _infoRow(Icons.cake_outlined, 'Age', '${profile?.age ?? 0} years'),
                        _infoRow(Icons.favorite_outline, 'Gender', profile?.gender ?? ''),
                        _infoRow(Icons.water_drop_outlined, 'Blood Group', profile?.bloodGroup ?? ''),
                        _infoRow(Icons.phone_outlined, 'Mobile', profile?.mobile ?? ''),
                        _infoRow(Icons.location_on_outlined, 'City', profile?.city ?? ''),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Emergency Contacts (array-based)
                  if (profile != null && profile!.emergencyNames.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Emergency Contacts',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const Divider(),
                          ...List.generate(profile!.emergencyNames.length, (i) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Colors.red.shade50,
                                child: const Icon(Icons.phone, color: Colors.red),
                              ),
                              title: Text(profile!.emergencyNames[i]),
                              subtitle: Text(
                                  '${profile!.emergencyRelations.length > i ? profile!.emergencyRelations[i] : ''} · ${profile!.emergencyPhones.length > i ? profile!.emergencyPhones[i] : ''}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.phone, color: Colors.green),
                                onPressed: () {},
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Caregivers (array-based)
                  if (profile != null && profile!.caregiverNames.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Caregivers',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const Divider(),
                          ...List.generate(profile!.caregiverNames.length, (i) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade50,
                                child: Icon(Icons.medical_services,
                                    color: Colors.blue.shade700),
                              ),
                              title: Text(profile!.caregiverNames[i]),
                              subtitle: Text(
                                  '${profile!.caregiverDesignations.length > i ? profile!.caregiverDesignations[i] : ''} · ${profile!.caregiverPhones.length > i ? profile!.caregiverPhones[i] : ''}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.phone, color: Colors.green),
                                onPressed: () {},
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await SupabaseService.signOut();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
