import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:openfoodfacts/model/BadgeBase.dart';
import 'package:openfoodfacts/model/EventCreate.dart';
import 'package:openfoodfacts/model/EventsBase.dart';
import 'package:openfoodfacts/model/LeaderboardEntry.dart';
import 'package:openfoodfacts/model/User.dart';

import 'utils/HttpHelper.dart';
import 'utils/QueryType.dart';
import 'utils/UriHelper.dart';

/// Client calls of the Events API (Open Food Facts).
///
/// cf. https://events.openfoodfacts.net/docs
class EventsAPIClient {
  EventsAPIClient._();

  /// Returns all the [EventsBase], with optional filters and paging.
  static Future<List<EventsBase>> getEvents({
    final String? userId,
    final String? deviceId,
    final int? skip,
    final int? limit,
    final QueryType? queryType,
  }) async {
    final Map<String, String> parameters = <String, String>{};
    if (userId != null) {
      parameters['user_id'] = userId;
    }
    if (deviceId != null) {
      parameters['device_id'] = deviceId;
    }
    if (skip != null) {
      parameters['skip'] = skip.toString();
    }
    if (limit != null) {
      parameters['limit'] = limit.toString();
    }
    final Response response = await HttpHelper().doGetRequest(
      UriHelper.getEventsUri(
        path: '/events',
        queryParameters: parameters,
        queryType: queryType,
      ),
      queryType: queryType,
    );
    _checkResponse(response);
    final List<EventsBase> result = <EventsBase>[];
    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    for (var element in json) {
      result.add(EventsBase.fromJson(element));
    }
    return result;
  }

  /// Returns all the events counts, with optional filters.
  static Future<Map<String, int>> getEventsCount({
    final String? userId,
    final String? deviceId,
    final QueryType? queryType,
  }) async {
    final Map<String, String> parameters = <String, String>{};
    if (userId != null) {
      parameters['user_id'] = userId;
    }
    if (deviceId != null) {
      parameters['device_id'] = deviceId;
    }
    final Response response = await HttpHelper().doGetRequest(
      UriHelper.getEventsUri(
        path: '/events/count',
        queryParameters: parameters,
        queryType: queryType,
      ),
      queryType: queryType,
    );
    _checkResponse(response);
    final Map<String, int> result = <String, int>{};
    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    for (final String key in json.keys) {
      result[key] = json[key] as int;
    }
    return result;
  }

  /// Returns the score, with optional filters.
  static Future<int> getScores({
    final String? userId,
    final String? deviceId,
    final String? eventType,
    final QueryType? queryType,
  }) async {
    final Map<String, String> parameters = <String, String>{};
    if (userId != null) {
      parameters['user_id'] = userId;
    }
    if (deviceId != null) {
      parameters['device_id'] = deviceId;
    }
    if (eventType != null) {
      parameters['event_type'] = eventType;
    }
    final Response response = await HttpHelper().doGetRequest(
      UriHelper.getEventsUri(
        path: '/scores',
        queryParameters: parameters,
        queryType: queryType,
      ),
      queryType: queryType,
    );
    _checkResponse(response);
    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    return json['score'] as int;
  }

  /// Returns all the [BadgeBase], with optional filters.
  static Future<List<BadgeBase>> getBadges({
    final String? userId,
    final String? deviceId,
    final QueryType? queryType,
  }) async {
    final Map<String, String> parameters = <String, String>{};
    if (userId != null) {
      parameters['user_id'] = userId;
    }
    if (deviceId != null) {
      parameters['device_id'] = deviceId;
    }
    final Response response = await HttpHelper().doGetRequest(
      UriHelper.getEventsUri(
        path: '/badges',
        queryParameters: parameters,
        queryType: queryType,
      ),
      queryType: queryType,
    );
    _checkResponse(response);
    final List<BadgeBase> result = <BadgeBase>[];
    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    for (var element in json) {
      result.add(BadgeBase.fromJson(element));
    }
    return result;
  }

  /// Returns all the [LeaderboardEntry], with optional filters.
  static Future<List<LeaderboardEntry>> getLeaderboard({
    final String? eventType,
    final QueryType? queryType,
  }) async {
    final Map<String, String> parameters = <String, String>{};
    if (eventType != null) {
      parameters['event_type'] = eventType;
    }
    final Response response = await HttpHelper().doGetRequest(
      UriHelper.getEventsUri(
        path: '/leaderboard',
        queryParameters: parameters,
        queryType: queryType,
      ),
      queryType: queryType,
    );
    _checkResponse(response);
    final List<LeaderboardEntry> result = <LeaderboardEntry>[];
    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    for (var element in json) {
      result.add(LeaderboardEntry.fromJson(element));
    }
    return result;
  }

  /// Adds an event.
  static Future<void> createEvent({
    required final EventCreate eventCreate,
    required final User user,
    final QueryType? queryType,
  }) async {
    final Response response = await HttpHelper().doPostRequest(
      UriHelper.getEventsUri(
        path: '/events',
        queryType: queryType,
      ),
      eventCreate.toData(),
      user,
      queryType: queryType,
    );
    _checkResponse(response);
  }

  /// Throws a detailed exception if relevant. Does nothing if [response] is OK.
  static void _checkResponse(final Response response) {
    if (response.statusCode != 200) {
      // cf. HTTPValidationError
      String? exception;
      try {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;
        exception = json['detail'];
      } catch (e) {
        //
      }
      if (exception != null) {
        throw Exception(exception);
      }
      // TODO(monsieurtanuki): have a look at ValidationError in https://events.openfoodfacts.org/docs
      throw Exception('Wrong status code: ${response.statusCode}');
    }
  }
}
