import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// In-memory implementation of the Cash Overflow API used by widget tests.
class FakeBackend {
  FakeBackend({this.role = 'Owner'});

  /// Role returned by `GET /me`.
  final String role;

  final List<http.Request> requests = [];

  late final MockClient client = MockClient((request) async {
    requests.add(request);
    final path = request.url.path.replaceFirst('/v1', '');
    final body = _route(request.method, path, request.url.queryParameters);
    if (body == null) return http.Response('{"message":"Not found"}', 404);
    return http.Response(
      jsonEncode(body),
      200,
      headers: {'content-type': 'application/json'},
    );
  });

  Object? _route(String method, String path, Map<String, String> query) {
    if (method == 'DELETE' && path.startsWith('/team/member/')) {
      return {'message': 'Member removed'};
    }

    switch ('$method $path') {
      case 'POST /logout':
        return {'message': 'Logged out'};
      case 'POST /Checkout/create-session':
        return {
          'sessionId': 'cs_test',
          'checkoutUrl': 'https://checkout.stripe.com/c/pay/cs_test',
        };
      case 'POST /onboarding/accept-invite':
        return {'message': 'Password set'};
      case 'POST /login':
        return {
          'token': 'test-token',
          'message': 'User logged in successfully',
        };
      case 'GET /me':
        return {
          'firstName': 'Sarah',
          'lastName': 'Mitchell',
          'email': 'sarah@company.com',
          'role': role,
          'companyId': 'ORG-001',
        };
      case 'GET /kpis':
        return {
          'cashOnHand': 1250000,
          'minCashBuffer': 600000,
          'receivablesOutstanding': 480000,
          'receivablesOverdue': 86000,
          'payablesOutstanding': 310000,
          'creditLineAvailable': 250000,
        };
      case 'GET /forecast':
        final days = int.tryParse(query['horizonDays'] ?? '') ?? 30;
        final start = DateTime(2026, 9, 1);
        return {
          'startCashOnHand': 1250000,
          'minCashBuffer': 600000,
          'horizonDays': days,
          'dailyForecast': [
            for (int i = 0; i < days; i++)
              {
                'date': start.add(Duration(days: i)).toIso8601String(),
                'expectedCash': 1250000 - i * 9000,
                'pessimisticCash': 1150000 - i * 14000,
                'optimisticCash': 1350000 - i * 4000,
                'netCashFlow': -9000,
              },
          ],
        };
      case 'GET /risks':
        return {
          'signals': [
            {
              'risk_type': 'Concentration',
              'severity': 'high',
              'headline':
                  '37% of outstanding receivables sit with a single customer.',
            },
            {
              'risk_type': 'Overdue',
              'severity': 'medium',
              'headline': '18% of receivables are more than 60 days past due.',
            },
          ],
        };
      case 'GET /explanation':
        return {
          'recommendations': [
            for (final tag in [
              '# Delay payments',
              '# Collect invoices',
              '# Keep buffer',
            ])
              {
                'tag': tag,
                'title':
                    'Consider delaying \$12K in non-essential payments until Oct 25 to keep the projected balance above the buffer.',
                'points': [
                  '+\$12K Cash preserved',
                  '14 days Flexibility gained',
                ],
              },
          ],
        };
      case 'GET /team/members':
        return [
          {
            'id': '1',
            'name': 'Sarah Mitchell',
            'email': 'sarah@company.com',
            'position': 'Owner',
          },
          {
            'id': '2',
            'name': 'Michael Anderson',
            'email': 'michael.anderson@company.com',
            'position': 'FinanceManager',
          },
        ];
      case 'GET /subscription':
        return {
          'id': 'sub_1',
          'subscriptionPlan': 'Pro',
          'status': 'active',
          'startDate': '2026-09-09',
          'cardBrand': 'Visa',
          'last4': '4242',
        };
      case 'GET /subscription/billing-history':
        return [
          {
            'transaction_id': 'txn_0001',
            'email': 'sarah@company.com',
            'plan': 'Pro',
            'amount': 499,
            'status': 'Succeeded',
            'date': '2026-09-09',
          },
        ];
      case 'GET /onboarding/demo-requests':
        return [
          {
            'id': 'a1',
            'companyName': 'Acme Retail',
            'companyEmail': 'finance@acme.com',
            'phoneNumber': '+201001234567',
            'submittedAt': '2026-09-02T10:00:00Z',
            'status': 'pending',
          },
          {
            'id': 'b2',
            'companyName': 'Nile Logistics',
            'companyEmail': 'cfo@nile.com',
            'phoneNumber': '+201112223334',
            'submittedAt': '2026-09-20T10:00:00Z',
            'status': 'Contacted',
          },
        ];
    }
    return null;
  }
}
