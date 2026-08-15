import '../main.dart';
import '../models/medicine.dart';
import '../models/schedule.dart';
import '../models/alert.dart';
import '../models/user_profile.dart';
import '../models/patient_summary.dart';

class SupabaseService {
  static Future<bool> signIn(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> signUp(String email, String password, String role) async {
    try {
      final res = await supabase.auth.signUp(email: email, password: password);
      if (res.user != null) {
        await supabase.from('profiles').upsert({
          'id': res.user!.id,
          'role': role,
          'full_name': '',
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  static String? get currentUserId => supabase.auth.currentUser?.id;

  static Future<UserProfile?> getProfile() async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', currentUserId!)
        .maybeSingle();
    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  // ─── Patient data ───
  static Future<List<Medicine>> getMedicines(String userId) async {
    final response = await supabase
        .from('medicines')
        .select()
        .eq('user_id', userId)
        .order('slot_number');
    return response.map((j) => Medicine.fromJson(j)).toList();
  }

  static Future<List<Schedule>> getSchedules(String userId) async {
    final response = await supabase
        .from('schedules')
        .select()
        .eq('user_id', userId)
        .order('time');
    return response.map((j) => Schedule.fromJson(j)).toList();
  }

  static Future<List<Alert>> getAlerts({String? patientId, bool forCurrentUser = false}) async {
    var query = supabase.from('alerts').select();
    if (patientId != null) {
      query = query.eq('patient_id', patientId);
    } else if (forCurrentUser) {
      query = query.eq('user_id', currentUserId!);
    }
    final response = await query.order('created_at', ascending: false);
    return response.map((j) => Alert.fromJson(j)).toList();
  }

  // ─── Stakeholder: assigned patients ───
  static Future<List<PatientSummary>> getAssignedPatients(String role) async {
    // TODO: Replace with real Supabase RPC or join query
    // For hackathon/demo, returning mock data shaped like SQL response
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      PatientSummary(
        id: 'p1',
        name: 'Vijay Kumar',
        age: 54,
        bloodGroup: 'O+',
        adherence: 0.92,
        status: 'Stable',
        isOnline: true,
        lastActive: '8:03 AM',
        nextMedName: 'Vitamin D',
        nextMedTime: '8:00 PM',
        deviceStatus: 'Online',
        stockStatus: 'Good',
      ),
      PatientSummary(
        id: 'p2',
        name: 'Anita Patel',
        age: 48,
        adherence: 0.71,
        status: 'Attention',
        isOnline: true,
        lastActive: '9:15 AM',
        nextMedName: 'Amlodipine',
        nextMedTime: '6:00 PM',
        deviceStatus: 'Online',
        stockStatus: 'Low',
      ),
      PatientSummary(
        id: 'p3',
        name: 'Ravi Singh',
        age: 62,
        adherence: 0.95,
        status: 'Stable',
        isOnline: true,
        lastActive: '7:45 AM',
        nextMedName: 'Metformin',
        nextMedTime: '10:00 PM',
        deviceStatus: 'Online',
        stockStatus: 'Good',
      ),
      PatientSummary(
        id: 'p4',
        name: 'Meera Joshi',
        age: 38,
        adherence: 0.58,
        status: 'Critical',
        isOnline: false,
        lastActive: 'Yesterday',
        nextMedName: 'Atorvastatin',
        nextMedTime: '1:00 PM',
        deviceStatus: 'Offline',
        stockStatus: 'Critical',
      ),
    ];
  }

  static Future<Map<String, dynamic>?> getPatientDetail(String patientId) async {
    // TODO: Wire to Supabase
    return null;
  }
  static Future<void> addSchedule(Map<String, dynamic> data) async {
    await supabase.from('schedules').insert({...data, 'user_id': currentUserId});
  }
}
