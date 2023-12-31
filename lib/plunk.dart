library plunk;

import 'dart:convert';

import 'package:rest_client/rest_client.dart';

part 'src/contacts.dart';
part 'src/emails.dart';
part 'src/events.dart';
part 'src/exceptions.dart';

/// Primary API entry class. Instantiate this class to initialize an
/// API connection, then use it's methods to call API methods.
class Plunk {
  final String apiKey, apiVersion, baseUrl;
  final Duration timeout;
  final bool? useIsolate;

  final TokenAuthorizer _authorizer;
  final String _baseUrl;
  final Client _client;

  Plunk({
    required this.apiKey,
    this.apiVersion = 'v1',
    this.baseUrl = 'https://api.useplunk.com',
    this.timeout = const Duration(seconds: 60),
    this.useIsolate,
  })  : _authorizer = TokenAuthorizer(token: apiKey),
        _baseUrl = '$baseUrl/$apiVersion',
        _client = Client(timeout: timeout, useIsolate: useIsolate);

  /// Triggers an event and creates it if it doesn't exist.
  /// This endpoint can be accessed with both the public and
  /// private API keys, meaning that you can trigger events
  /// from both the client and the server.
  /// Return a [TrackResponse] object containing the success
  /// status, contact ID, event ID, and timestamp.
  Future<TrackResponse> track(String email, String event) async {
    final trackRequest = TrackRequest(email: email, event: event);

    final request = Request(
      body: trackRequest.toJson(),
      method: RequestMethod.post,
      url: '$_baseUrl/${TrackRequest.resourcePath}',
    );

    final response = await _client.execute(
      authorizer: _authorizer,
      request: request,
    );

    switch (response.statusCode) {
      case 200:
        return TrackResponse.fromMap(response.body);
      case 400:
        throw PlunkInvalidRequestException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 401:
        throw PlunkAuthorizationException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 402:
        throw PlunkQuotaException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      default:
        throw PlunkUnknownException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
    }
  }

  /// Gets the details of a specific contact.
  /// This endpoint can only be accessed with a secret API key.
  /// Returns a [ContactResponse] object containing the contact's
  /// details.
  Future<ContactResponse> contact(String contactId) async {
    if (contactId.isEmpty) {
      throw PlunkInvalidRequestException(
        code: '404',
        message: 'Invalid contactId parameter',
      );
    }

    final request = Request(
      method: RequestMethod.get,
      url: '$_baseUrl/${ContactRequest.resourcePath}/$contactId',
    );

    final response = await _client.execute(
      authorizer: _authorizer,
      request: request,
    );

    switch (response.statusCode) {
      case 200:
        return ContactResponse.fromMap(response.body);
      case 400:
        throw PlunkInvalidRequestException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 401:
        throw PlunkAuthorizationException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 402:
        throw PlunkQuotaException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      default:
        throw PlunkUnknownException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
    }
  }

  /// Get a list of all contacts in your Plunk account.
  /// This endpoint can only be accessed with a secret API key
  /// as it returns sensitive information.
  /// Returns an array of [ContactResponse] objects.
  Future<List<ContactResponse>> contacts() async {
    final request = Request(
      method: RequestMethod.get,
      url: '$_baseUrl/${ContactRequest.resourcePath}',
    );

    final response = await _client.execute(
      authorizer: _authorizer,
      request: request,
    );

    switch (response.statusCode) {
      case 200:
        return List<ContactResponse>.from(
          response.body.map((contact) => ContactResponse.fromMap(contact)),
        );
      case 400:
        throw PlunkInvalidRequestException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 401:
        throw PlunkAuthorizationException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 402:
        throw PlunkQuotaException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      default:
        throw PlunkUnknownException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
    }
  }

  /// Fetches the total number of contacts in your Plunk account.
  /// Useful for displaying the number of contacts in a dashboard,
  /// landing page or other marketing material.
  /// This endpoint can be accessed with either a secret API key or
  /// a public API key.
  /// Returns an integer representing the amount of contacts in your
  /// Plunk account.
  Future<int> count() async {
    final request = Request(
      method: RequestMethod.get,
      url: '$_baseUrl/${ContactRequest.resourcePath}/count',
    );

    final response = await _client.execute(
      authorizer: _authorizer,
      request: request,
    );

    switch (response.statusCode) {
      case 200:
        return response.body['count'];
      case 400:
        throw PlunkInvalidRequestException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 401:
        throw PlunkAuthorizationException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 402:
        throw PlunkQuotaException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      default:
        throw PlunkUnknownException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
    }
  }

  /// Used to create a new contact in your Plunk project without
  /// triggering an event.
  /// This endpoint can only be accessed with a secret API key.
  /// Returns a [ContactResponse] object.
  Future<ContactResponse> create(
    String email,
    bool subscribed,
    Map<String, dynamic> data,
  ) async {
    final contact = ContactRequest(
      email: email,
      subscribed: subscribed,
      data: data,
    );

    final request = Request(
      body: contact.toJson(),
      method: RequestMethod.post,
      url: '$_baseUrl/${ContactRequest.resourcePath}',
    );

    final response = await _client.execute(
      authorizer: _authorizer,
      request: request,
    );

    switch (response.statusCode) {
      case 200:
        return ContactResponse.fromMap(response.body);
      case 400:
        throw PlunkInvalidRequestException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 401:
        throw PlunkAuthorizationException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 402:
        throw PlunkQuotaException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      default:
        throw PlunkUnknownException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
    }
  }

  /// Updates a contact's subscription status to subscribed.
  /// This endpoint can be accessed with either a secret API
  /// key or a public API key.
  /// Returns a [SubscriptionResponse] object.
  Future<SubscriptionResponse> subscribe(String contactId) async {
    final request = Request(
      body: jsonEncode({'id': contactId}),
      method: RequestMethod.post,
      url: '$_baseUrl/${ContactRequest.resourcePath}/subscribe',
    );

    final response = await _client.execute(
      authorizer: _authorizer,
      request: request,
    );

    switch (response.statusCode) {
      case 200:
        return SubscriptionResponse.fromMap(response.body);
      case 400:
        throw PlunkInvalidRequestException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 401:
        throw PlunkAuthorizationException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 402:
        throw PlunkQuotaException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      default:
        throw PlunkUnknownException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
    }
  }

  /// Updates a contact's subscription status to unsubscribed.
  /// This endpoint can be accessed with either a secret API
  /// key or a public API key.
  /// Returns a [SubscriptionResponse] object.
  Future<SubscriptionResponse> unsubscribe(String contactId) async {
    final request = Request(
      body: jsonEncode({'id': contactId}),
      method: RequestMethod.post,
      url: '$_baseUrl/${ContactRequest.resourcePath}/unsubscribe',
    );

    final response = await _client.execute(
      authorizer: _authorizer,
      request: request,
    );

    switch (response.statusCode) {
      case 200:
        return SubscriptionResponse.fromMap(response.body);
      case 400:
        throw PlunkInvalidRequestException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 401:
        throw PlunkAuthorizationException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 402:
        throw PlunkQuotaException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      default:
        throw PlunkUnknownException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
    }
  }

  /// Used to send transactional emails to a single recipient or multiple
  /// recipients at once. Transactional emails are programmatically sent
  /// emails that are considered to be part of your application's workflow.
  /// This could be a password reset email, a billing email or other
  /// non-marketing emails.
  /// This endpoint can only be accessed with a secret key.
  /// Returns a [SendResponse] object.
  Future<SendResponse> send(
    String from,
    List<String> to,
    String subject,
    String body,
    String? name,
  ) async {
    final sendRequest = SendRequest(
      from: from,
      to: to,
      subject: subject,
      body: body,
      name: name,
    );

    final request = Request(
      body: sendRequest.toJson(),
      method: RequestMethod.post,
      url: '$_baseUrl/${SendRequest.resourcePath}',
    );

    final response = await _client.execute(
      authorizer: _authorizer,
      request: request,
    );

    switch (response.statusCode) {
      case 200:
        return SendResponse.fromMap(response.body);
      case 400:
        throw PlunkInvalidRequestException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 401:
        throw PlunkAuthorizationException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 402:
        throw PlunkQuotaException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      default:
        throw PlunkUnknownException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
    }
  }

  /// Deletes a contact.
  /// This endpoint can only be accessed with a secret API key.
  /// It returns the data how it was at the time of deletion, as a
  /// [ContactResponse] object.
  /// After the request the data is removed from your Plunk dashboard.
  Future<ContactResponse> delete(String contactId) async {
    final request = Request(
      body: jsonEncode({'id': contactId}),
      method: RequestMethod.delete,
      url: '$_baseUrl/${ContactRequest.resourcePath}',
    );

    final response = await _client.execute(
      authorizer: _authorizer,
      request: request,
    );

    switch (response.statusCode) {
      case 200:
        return ContactResponse.fromMap(response.body);
      case 400:
        throw PlunkInvalidRequestException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 401:
        throw PlunkAuthorizationException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      case 402:
        throw PlunkQuotaException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
      default:
        throw PlunkUnknownException(
          code: response.statusCode.toString(),
          message: response.body.toString(),
        );
    }
  }
}
