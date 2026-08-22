import 'package:flutter/material.dart';

import '../main.dart';
import '../models/medicine.dart';
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

  static Future<List<Alert>> getAlerts({
    String? patientId,
    bool forCurrentUser = false,
  }) async {
    var query = supabase.from('alerts').select();
    if (patientId != null) {
      query = query.eq('patient_id', patientId);
    } else if (forCurrentUser) {
      query = query.eq('user_id', currentUserId!);
    }
    final response = await query.order('created_at', ascending: false);
    return response.map((j) => Alert.fromJson(j)).toList();
  }

  static Future<Map<String, dynamic>?> getPatientDetail(
    String patientId,
  ) async {
    // TODO: Wire to Supabase
    return null;
  }

  // ─── Device ───
  static Future<Map<String, dynamic>?> getDeviceForPatient(
    String patientId,
  ) async {
    final access = await supabase
        .from('device_access')
        .select('device_id, devices(*)')
        .eq('user_id', patientId)
        .maybeSingle();
    if (access == null) return null;
    return access['devices'] as Map<String, dynamic>?;
  }

  // ─── Real assigned patients (caretaker & doctor) ───
  static Future<List<PatientSummary>> getAssignedPatients(
    String role,
    String userId,
  ) async {
    try {
      final idColumn = role == 'doctor' ? 'doctor_id' : 'caretaker_id';
      final rels = await supabase
          .from('care_relationships')
          .select('patient_id')
          .eq(idColumn, userId)
          .eq('status', 'active');

      final patientIds = rels.map((r) => r['patient_id'] as String).toList();
      if (patientIds.isEmpty) return [];

      final profiles = await supabase
          .from('profiles')
          .select()
          .inFilter('id', patientIds);
      return profiles
          .map(
            (j) => PatientSummary.fromJson({
              'patient_id': j['id'],
              'full_name': j['full_name'],
              'age': j['age'],
              'blood_group': j['blood_group'],
              'adherence': 0.92,
              'status': 'Stable',
              'is_online': true,
            }),
          )
          .toList();
    } catch (e) {
      debugPrint('getAssignedPatients error: $e');
      return [];
    }
  }

  // ─── Stakeholder alerts (caretaker/doctor only see their patients) ───
  static Future<List<Alert>> getAlertsForStakeholder(
    String userId,
    String role,
  ) async {
    final idColumn = role == 'doctor' ? 'doctor_id' : 'caretaker_id';
    final rels = await supabase
        .from('care_relationships')
        .select('patient_id')
        .eq(idColumn, userId)
        .eq('status', 'active');
    final patientIds = rels.map((r) => r['patient_id'] as String).toList();
    if (patientIds.isEmpty) return [];

    var query = supabase
        .from('alerts')
        .select()
        .inFilter('patient_id', patientIds);

    // Caretakers don't need to see request alerts
    if (role == 'caretaker') {
      query = query.neq('type', 'request');
    }

    final response = await query.order('created_at', ascending: false);
    return response.map((j) => Alert.fromJson(j)).toList();
  }

  // ─── Doctor assigns patient by email ───
  static Future<bool> requestPatientAccess(
    String doctorId,
    String patientEmail,
  ) async {
    final patient = await supabase
        .from('profiles')
        .select('id')
        .eq('email', patientEmail)
        .maybeSingle();
    if (patient == null) return false;

    await supabase.from('care_relationships').insert({
      'doctor_id': doctorId,
      'patient_id': patient['id'],
      'status': 'pending',
      'can_manage_meds': true,
      'can_manage_schedules': true,
    });

    await supabase.from('alerts').insert({
      'user_id': patient['id'],
      'patient_id': patient['id'],
      'type': 'request',
      'title': 'Doctor Access Request',
      'message':
          'Dr. Rajesh Sharma wants to monitor your medications. Tap to approve.',
      'severity': 'normal',
    });
    return true;
  }

  // ─── Patient approves/rejects doctor ───
  static Future<void> respondToRequest(
    String relationshipId,
    bool approve,
  ) async {
    await supabase
        .from('care_relationships')
        .update({'status': approve ? 'active' : 'rejected'})
        .eq('id', relationshipId);
  }

  // ─── Demo: caregiver dispenses now ───
  static Future<void> dispenseNow(
    String patientId,
    String medicineId,
    int slot,
  ) async {
    await supabase.from('dispense_logs').insert({
      'user_id': patientId,
      'medicine_id': medicineId,
      'slot_number': slot,
      'scheduled_time': DateTime.now().toIso8601String(),
      'dispensed_at': DateTime.now().toIso8601String(),
      'status': 'pending',
    });
  }

  static Future<void> respondToAccessRequest(
    String alertId,
    bool accept,
  ) async {
    final alert = await supabase
        .from('alerts')
        .select()
        .eq('id', alertId)
        .single();
    final patientId = alert['patient_id'] as String;

    final rel = await supabase
        .from('care_relationships')
        .select()
        .eq('patient_id', patientId)
        .eq('status', 'pending')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (rel != null) {
      await supabase
          .from('care_relationships')
          .update({'status': accept ? 'active' : 'rejected'})
          .eq('id', rel['id']);
    }

    await supabase
        .from('alerts')
        .update({
          'request_status': accept ? 'accepted' : 'rejected',
          'read': true,
        })
        .eq('id', alertId);
  }

  static Future<int> getSlotCount(String userId) async {
    final device = await getDeviceForPatient(userId);
    return device?['slot_count'] ?? 4;
  }

  static Future<void> upsertMedicine(Map<String, dynamic> data) async {
    final existing = await supabase
        .from('medicines')
        .select('id')
        .eq('user_id', currentUserId!)
        .eq('slot_number', data['slot_number'])
        .maybeSingle();

    if (existing != null) {
      await supabase.from('medicines').update(data).eq('id', existing['id']);
    } else {
      await supabase.from('medicines').insert({
        ...data,
        'user_id': currentUserId,
      });
    }
  }

  // ─── Update medicine schedule fields directly (merged from schedules table) ───
  static Future<void> updateMedicineById(
    String medicineId,
    Map<String, dynamic> data,
  ) async {
    await supabase.from('medicines').update(data).eq('id', medicineId);
  }

    static Future<void> undoAccessRequest(String alertId) async {
    final alert = await supabase.from('alerts').select().eq('id', alertId).single();
    final patientId = alert['patient_id'] as String;

    final rel = await supabase
        .from('care_relationships')
        .select()
        .eq('patient_id', patientId)
        .or('status.eq.active,status.eq.rejected')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (rel != null) {
      final stakeholderId = rel['doctor_id'] as String? ?? rel['caretaker_id'] as String?;

      if (rel['status'] == 'active' && stakeholderId != null) {
        final stakeholder = await supabase
            .from('profiles')
            .select('full_name')
            .eq('id', stakeholderId)
            .maybeSingle();

        if (stakeholder != null) {
          final name = stakeholder['full_name'] as String? ?? '';
          final profile = await supabase.from('profiles').select().eq('id', patientId).single();

          final names = List<String>.from(profile['emergency_name'] ?? []);
          final relations = List<String>.from(profile['emergency_relation'] ?? []);
          final phones = List<String>.from(profile['emergency_phone'] ?? []);

          // Remove ALL occurrences of this doctor (backwards to keep indices valid)
          for (int i = names.length - 1; i >= 0; i--) {
            if (names[i] == name) {
              names.removeAt(i);
              if (i < relations.length) relations.removeAt(i);
              if (i < phones.length) phones.removeAt(i);
            }
          }

          await supabase.from('profiles').update({
            'emergency_name': names,
            'emergency_relation': relations,
            'emergency_phone': phones,
          }).eq('id', patientId);
        }
      }

      await supabase.from('care_relationships').update({
        'status': 'pending'
      }).eq('id', rel['id']);
    }

    await supabase.from('alerts').update({
      'request_status': 'pending',
      'read': false,
    }).eq('id', alertId);
  }

    // ─── Doctor helpers ───
  static Future<int> getPatientCount(String doctorId) async {
    final res = await supabase
        .from('care_relationships')
        .select('id')
        .eq('doctor_id', doctorId)
        .eq('status', 'active');
    return res.length;
  }

  static Future<List<Alert>> getUrgentAlerts(String doctorId) async {
    final rels = await supabase
        .from('care_relationships')
        .select('patient_id')
        .eq('doctor_id', doctorId)
        .eq('status', 'active');
    final patientIds = rels.map((r) => r['patient_id'] as String).toList();
    if (patientIds.isEmpty) return [];

    final response = await supabase
        .from('alerts')
        .select()
        .inFilter('patient_id', patientIds)
        .eq('severity', 'urgent')
        .order('created_at', ascending: false);
    return response.map((j) => Alert.fromJson(j)).toList();
  }

    static Future<Map<String, dynamic>?> getCaretakerForPatient(String patientId) async {
    final rel = await supabase
        .from('care_relationships')
        .select('caretaker_id')
        .eq('patient_id', patientId)
        .eq('status', 'active')
        .maybeSingle();
    if (rel == null || rel['caretaker_id'] == null) return null;

    final profile = await supabase
        .from('profiles')
        .select('full_name, mobile')
        .eq('id', rel['caretaker_id'])
        .maybeSingle();
    return profile;
  }

  static Future<List<Map<String, dynamic>>> getCaretakersForPatient(String patientId) async {
    final rels = await supabase
        .from('care_relationships')
        .select('caretaker_id')
        .eq('patient_id', patientId)
        .eq('status', 'active');

    final ids = rels
        .where((r) => r['caretaker_id'] != null)
        .map((r) => r['caretaker_id'] as String)
        .toList();
    if (ids.isEmpty) return [];

    final profiles = await supabase
        .from('profiles')
        .select('full_name, mobile')
        .inFilter('id', ids);
    return List<Map<String, dynamic>>.from(profiles);
  }

  static Future<void> removePatientAccess(String doctorId, String patientId) async {
    await supabase
        .from('care_relationships')
        .delete()
        .eq('doctor_id', doctorId)
        .eq('patient_id', patientId);
  }

  static Future<UserProfile?> getPatientProfile(String patientId) async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', patientId)
        .maybeSingle();
    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  static Future<List<Medicine>> getPatientMedicines(String patientId) async {
    final response = await supabase
        .from('medicines')
        .select()
        .eq('user_id', patientId)
        .order('slot_number');
    return response.map((j) => Medicine.fromJson(j)).toList();
  }

  static Future<List<Map<String, dynamic>>> getPatientDispenseLogs(String patientId) async {
    final response = await supabase
        .from('dispense_logs')
        .select()
        .eq('user_id', patientId)
        .order('scheduled_time', ascending: false)
        .limit(30);
    return List<Map<String, dynamic>>.from(response);
  }
}
