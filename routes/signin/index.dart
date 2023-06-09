import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../helpers/helpers.dart';
import '../../models/models.dart';
import '../../services/mongo_service.dart';
import '../_middleware.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    final request = context.request;
    final mongoService = await context.read<Future<MongoService>>();

    if (request.method == HttpMethod.post) {
      await mongoService.open();

      final requestBody = await request.body();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;
      final user = User.fromMap(requestData);

      final usersCollection = mongoDbService.database.collection('users');

      final foundUser = await usersCollection.findOne({'email': user.email});

      if (foundUser == null) {
        return Response.json(
          statusCode: 400,
          body: {
            'status': 400,
            'message': 'No user found with the provided credentials',
            'error': 'user_not_found',
          },
        );
      }
      final foundUserPassword = foundUser['password'] as String;
      final hashedPassword = hashPassword(
        user.password,
      );
      if (hashedPassword != foundUserPassword) {
        return Response.json(
          statusCode: 400,
          body: {
            'status': 400,
            'message': 'Incorrect email or password',
            'error': 'incorrect_email_password',
          },
        );
      }
      final foundUserId = (foundUser['_id'] as ObjectId).$oid;
      final token = issueToken(foundUserId);

      await mongoDbService.close();

      return Response.json(
        body: {
          'status': 200,
          'message': 'User logged in successfully',
          'token': token,
        },
      );
    } else {
      return Response.json(
        statusCode: 404,
        body: {
          'status': 404,
          'message': 'Invalid request',
        },
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'status': 500,
        'message': 'Server error. Something went wrong',
        'error': e.toString(),
      },
    );
  }
}
