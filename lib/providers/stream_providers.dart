import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:events_manager/models/announcement.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/models/event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:events_manager/models/map_marker.dart';
import 'package:events_manager/models/user.dart';
import 'package:events_manager/utils/firedata.dart';
import 'package:firebase_auth/firebase_auth.dart';

Stream<List<Map<String, dynamic>>> loadEventsStream() {
  final firestore = FirebaseFirestore.instance;
  final events = firestore.collection('events').snapshots();
  return events.map((event) => event.docs.map((doc) => doc.data()).toList());
}

Stream<List<Map<String, dynamic>>> loadTodaysEventsStream() {
  final firestore = FirebaseFirestore.instance;
  final now = DateTime.now();
  final startOfDay = now; // Current time
  final endOfDay = now.add(Duration(hours: 24)); // 24 hours from now

  return firestore
      .collection('events')
      .where('startTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
      .orderBy('startTime')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}

Stream<List<Map<String, dynamic>>> loadAnnouncementsStream() {
  final firestore = FirebaseFirestore.instance;
  return firestore.collection('announcements').snapshots().map((snapshot) {
    final List<Map<String, dynamic>> allAnnouncements = [];
    for (var doc in snapshot.docs) {
      if (doc.data().containsKey('announcementsList')) {
        final List<dynamic> announcementsList = doc.data()['announcementsList'];
        allAnnouncements.addAll(announcementsList.cast<Map<String, dynamic>>());
      }
    }
    allAnnouncements.sort((a, b) => b['date'].compareTo(a['date'])); //descending
    return allAnnouncements;
  });
}

final eventsStreamProvider = StreamProvider<List<Event>>((ref) {
  return loadEventsStream().map(
    (eventsList) =>
        eventsList.map((eventData) => Event.fromJson(eventData)).toList(),
  );
});

final todaysEventsStreamProvider = StreamProvider<List<Event>>((ref) {
  return loadTodaysEventsStream().map(
    (eventsList) =>
        eventsList.map((eventData) => Event.fromJson(eventData)).toList(),
  );
});

final announcementsStreamProvider = StreamProvider<List<Announcement>>((ref) {
  return loadAnnouncementsStream().map(
    (announcementsList) =>
        announcementsList.map((json) => Announcement.fromJson(json)).toList()
          ..sort((a, b) => b.date.compareTo(a.date)),
  );
});

// New providers for search functionality
final searchQueryProvider = StateProvider<String>((ref) => '');
final searchFilterProvider = StateProvider<String>((ref) => 'All');

final searchResultsProvider = Provider<List<dynamic>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final filter = ref.watch(searchFilterProvider);
  final events = ref.watch(eventsStreamProvider).value ?? [];
  final announcements = ref.watch(announcementsStreamProvider).value ?? [];
  final clubs = ref.watch(clubsStreamProvider).value ?? [];

  if (query.isEmpty) return [];

  List<dynamic> results = [];
  final searchQuery = query.toLowerCase();

  // Helper function to get club name
  String getClubName(String clubId) {
    final club = clubs.firstWhere(
      (club) => club.id == clubId,
      orElse: () => Club(id: '', name: '', logoUrl: '', backgroundImageUrl: ''),
    );
    return club.name;
  }

  if (filter == 'All' || filter == 'Events') {
    // Filter events by search query
    var filteredEvents = events.where((event) =>
        event.title.toLowerCase().contains(searchQuery) ||
        event.description.toLowerCase().contains(searchQuery) ||
        event.clubId.toLowerCase().contains(searchQuery) ||
        getClubName(event.clubId).toLowerCase().contains(searchQuery)).toList();

    // Sort events: upcoming first (sorted by start time), then past events (sorted by most recent)
    final now = DateTime.now();
    final upcomingEvents = filteredEvents.where((event) => event.startTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime)); // Earliest upcoming first
    final pastEvents = filteredEvents.where((event) => event.startTime.isBefore(now)).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime)); // Most recent past first

    // Combine the sorted lists
    filteredEvents = [...upcomingEvents, ...pastEvents];

    results.addAll(filteredEvents);
  }

  if (filter == 'All' || filter == 'Announcements') {
    // Announcements are already sorted by date in the announcementsStreamProvider
    results.addAll(announcements.where((announcement) =>
        announcement.title.toLowerCase().contains(searchQuery) ||
        announcement.subtitle.toLowerCase().contains(searchQuery) ||
        announcement.description.toLowerCase().contains(searchQuery) ||
        announcement.venue.toLowerCase().contains(searchQuery) ||
        announcement.time.toLowerCase().contains(searchQuery) ||
        announcement.clubId.toLowerCase().contains(searchQuery) ||
        getClubName(announcement.clubId).toLowerCase().contains(searchQuery)));
  }

  if (filter == 'All' || filter == 'Clubs') {
    // Sort clubs alphabetically by name
    var filteredClubs = clubs.where((club) =>
        club.name.toLowerCase().contains(searchQuery) ||
        club.id.toLowerCase().contains(searchQuery)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    results.addAll(filteredClubs);
  }

  return results;
});

// New providers for events page filtering
final eventsSearchQueryProvider = StateProvider<String>((ref) => '');
final eventsFilterClubProvider = StateProvider<String>((ref) => 'All Clubs');
final eventsViewOptionProvider = StateProvider<String>((ref) => 'All Events');

final filteredEventsProvider = Provider<List<Event>>((ref) {
  final searchQuery = ref.watch(eventsSearchQueryProvider);
  final filterClub = ref.watch(eventsFilterClubProvider);
  final viewOption = ref.watch(eventsViewOptionProvider);
  final events = ref.watch(eventsStreamProvider).value ?? [];

  // First filter by search query
  var filtered = searchQuery.isEmpty
      ? events
      : events
          .where((event) =>
              event.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              event.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
              (event.venue != null && event.venue!.toLowerCase().contains(searchQuery.toLowerCase())))
          .toList();

  // Then filter by club if not "All Clubs"
  if (filterClub != 'All Clubs') {
    filtered = filtered.where((event) => event.clubId == filterClub).toList();
  }

  // Then filter by view option
  final now = DateTime.now();
  switch (viewOption) {
    case 'Upcoming Events':
      filtered = filtered.where((event) => event.startTime.isAfter(now)).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime)); // Earliest first
      break;
    case 'Past Events':
      filtered = filtered.where((event) => event.startTime.isBefore(now)).toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime)); // Most recent first
      break;
    case 'All Events':
    default:
      // Sort upcoming first, then past events
      final upcomingEvents = filtered.where((event) => event.startTime.isAfter(now)).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      final pastEvents = filtered.where((event) => event.startTime.isBefore(now)).toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
      filtered = [...upcomingEvents, ...pastEvents];
      break;
  }

  return filtered;
});

// New providers for announcements page filtering
final announcementsSearchQueryProvider = StateProvider<String>((ref) => '');
final announcementsFilterClubProvider = StateProvider<String>((ref) => 'All Clubs');
final announcementsSortOptionProvider = StateProvider<String>((ref) => 'Newest First');

final filteredAnnouncementsProvider = Provider<List<Announcement>>((ref) {
  final searchQuery = ref.watch(announcementsSearchQueryProvider);
  final filterClub = ref.watch(announcementsFilterClubProvider);
  final sortOption = ref.watch(announcementsSortOptionProvider);
  final announcements = ref.watch(announcementsStreamProvider).value ?? [];

  // First filter by search query
  var filtered = searchQuery.isEmpty
      ? announcements
      : announcements
          .where((announcement) =>
              announcement.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              announcement.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
              announcement.subtitle.toLowerCase().contains(searchQuery.toLowerCase()) ||
              (announcement.venue.isNotEmpty && announcement.venue.toLowerCase().contains(searchQuery.toLowerCase())))
          .toList();

  // Then filter by club if not "All Clubs"
  if (filterClub != 'All Clubs') {
    filtered = filtered.where((announcement) => announcement.clubId == filterClub).toList();
  }

  // Then sort based on sort option
  switch (sortOption) {
    case 'Newest First':
      filtered.sort((a, b) => b.date.compareTo(a.date));
      break;
    case 'Oldest First':
      filtered.sort((a, b) => a.date.compareTo(b.date));
      break;
    default:
      filtered.sort((a, b) => b.date.compareTo(a.date)); // Default to newest first
  }

  return filtered;
});

Stream<List<Map<String, dynamic>>> loadClubsStream() {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('clubs')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}

final clubsStreamProvider = StreamProvider<List<Club>>((ref) {
  return loadClubsStream().map(
    (clubsList) =>
        clubsList.map((clubData) => Club.fromJson(clubData)).toList(),
  );
});

final mapMarkersProvider = FutureProvider<List<MapMarker>>((ref) async {
  return loadMapMarkers();
});


final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final auth = FirebaseAuth.instance;
  return auth.authStateChanges().asyncMap((user) async {
    if (user == null) return null;
    return AppUser.fromUid(user.uid);
  });
});



void invalidateAllProviders(WidgetRef ref) {
  ref.invalidate(eventsStreamProvider);
  ref.invalidate(todaysEventsStreamProvider);
  ref.invalidate(announcementsStreamProvider);
  ref.invalidate(clubsStreamProvider);
  ref.invalidate(searchResultsProvider);
  ref.invalidate(mapMarkersProvider);
  ref.invalidate(currentUserProvider);
  ref.invalidate(filteredEventsProvider);
  ref.invalidate(filteredAnnouncementsProvider);
}
