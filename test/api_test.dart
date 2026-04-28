import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:api_management_app/models/user.dart';
import 'package:api_management_app/services/api_service.dart';

const _usersJson = '''
[
  {
    "id": 1,
    "name": "Leanne Graham",
    "username": "Bret",
    "email": "Sincere@april.biz",
    "phone": "1-770-736-0860 x56442",
    "website": "hildegard.org",
    "address": {
      "street": "Kulas Light",
      "suite": "Apt. 556",
      "city": "Gwenborough",
      "zipcode": "92998-3874"
    },
    "company": {
      "name": "Romaguera-Crona",
      "catchPhrase": "Multi-layered client-server neural-net",
      "bs": "harness real-time e-markets"
    }
  }
]
''';

void main() {
  group('User model', () {
    test('fromJson parses all fields correctly', () {
      final json = (jsonDecode(_usersJson) as List<dynamic>).first
          as Map<String, dynamic>;
      final user = User.fromJson(json);

      expect(user.id, 1);
      expect(user.name, 'Leanne Graham');
      expect(user.username, 'Bret');
      expect(user.email, 'Sincere@april.biz');
      expect(user.phone, '1-770-736-0860 x56442');
      expect(user.website, 'hildegard.org');
      expect(user.address.city, 'Gwenborough');
      expect(user.company.name, 'Romaguera-Crona');
      expect(user.avatarUrl, 'https://i.pravatar.cc/150?img=1');
    });
  });

  group('ApiService', () {
    test('fetchUsers returns list of users on 200', () async {
      final client = MockClient((request) async {
        return http.Response(_usersJson, 200);
      });
      final service = ApiService(client: client);

      final users = await service.fetchUsers();
      expect(users.length, 1);
      expect(users.first.name, 'Leanne Graham');
    });

    test('fetchUsers throws ApiException on non-200', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });
      final service = ApiService(client: client);

      expect(() => service.fetchUsers(), throwsA(isA<ApiException>()));
    });

    test('fetchUser returns a single user on 200', () async {
      final singleJson = (jsonDecode(_usersJson) as List<dynamic>).first;
      final client = MockClient((request) async {
        return http.Response(jsonEncode(singleJson), 200);
      });
      final service = ApiService(client: client);

      final user = await service.fetchUser(1);
      expect(user.id, 1);
    });

    test('fetchUser throws ApiException on 500', () async {
      final client = MockClient((request) async {
        return http.Response('Server Error', 500);
      });
      final service = ApiService(client: client);

      expect(() => service.fetchUser(1), throwsA(isA<ApiException>()));
    });
  });
}
