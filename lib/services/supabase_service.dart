import '../main.dart';
import '../models/medicine.dart';
import '../models/schedule.dart';
import '../models/alert.dart';
import '../models/user_profile.dart';

class SupabaseService {
  // Auth
  static Future<bool> signIn(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  static String? get currentUserId => supabase.auth.currentUser?.id;

  // Medicines
  static Future<List<Medicine>> getMedicines() async {
    final response = await supabase
        .from('medicines')
        .select()
        .eq('user_id', currentUserId!)
        .order('slot_number');
    return response.map((j) => Medicine.fromJson(j)).toList();
  }

  static Future<void> updateMedicineQuantity(String id, int qty) async {
    await supabase.from('medicines').update({'quantity': qty}).eq('id', id);
  }

  // Schedules
  static Future<List<Schedule>> getSchedules() async {
    final response = await supabase
        .from('schedules')
        .select()
        .eq('user_id', currentUserId!)
        .order('time');
    return response.map((j) => Schedule.fromJson(j)).toList();
  }

  static Future<void> addSchedule(Map<String, dynamic> data) async {
    await supabase.from('schedules').insert({...data, 'user_id': currentUserId});
  }

  // Alerts
  static Future<List<Alert>> getAlerts() async {
    final response = await supabase
        .from('alerts')
        .select()
        .eq('user_id', currentUserId!)
        .order('created_at', ascending: false);
    return response.map((j) => Alert.fromJson(j)).toList();
  }

  // Profile
  static Future<UserProfile?> getProfile() async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', currentUserId!)
        .maybeSingle();
    if (response == null) return null;
    return UserProfile.fromJson(response);
  }
}
