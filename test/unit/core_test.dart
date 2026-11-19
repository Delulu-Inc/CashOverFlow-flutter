import 'package:cash_overflow/app/router/app_router.dart';
import 'package:cash_overflow/core/network/api_exception.dart';
import 'package:cash_overflow/core/utils/formatters.dart';
import 'package:cash_overflow/core/utils/validators.dart';
import 'package:cash_overflow/features/auth/data/models/current_user.dart';
import 'package:cash_overflow/features/dashboard/data/models/cash_forecast.dart';
import 'package:cash_overflow/features/onboarding/data/models/demo_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('accepts common e-mail formats', () {
      expect(Validators.isEmail('name@company.com'), isTrue);
      expect(Validators.isEmail('first.last+tag@my-company.co.uk'), isTrue);
      expect(Validators.isEmail('not-an-email'), isFalse);
      expect(Validators.isEmail('a@b'), isFalse);
    });

    test('validates names and phone numbers', () {
      expect(Validators.isPersonName('Sarah'), isTrue);
      expect(Validators.isPersonName('محمد'), isTrue);
      expect(Validators.isPersonName('Sarah2'), isFalse);
      expect(Validators.isPhoneNumber('+201001234567'), isTrue);
      expect(Validators.isPhoneNumber('0123'), isFalse);
    });
  });

  group('Formatters', () {
    test('compact currency', () {
      expect(Formatters.compactCurrency(1250000), '\$1.3M');
      expect(Formatters.compactCurrency(86000), '\$86.0K');
      expect(Formatters.compactCurrency(86000, thousandsDecimals: 0), '\$86K');
      expect(Formatters.compactCurrency(420), '\$420');
    });

    test('dates', () {
      final date = DateTime(2026, 9, 1);
      expect(Formatters.shortDate(date), '1 Sep 2026');
      expect(Formatters.dayMonth(date), '1 Sep');
      expect(Formatters.isoDate(date), '2026-09-01');
    });
  });

  group('AppRouter', () {
    test('normalizes GitHub Pages paths and trailing slashes', () {
      expect(AppRouter.normalizePath('/CashOverFlow-flutter/'), '/');
      expect(
        AppRouter.normalizePath('/CashOverFlow-flutter/dashboard'),
        '/dashboard',
      );
      expect(AppRouter.normalizePath('/dashboard/'), '/dashboard');
      expect(AppRouter.normalizePath(''), '/');
    });

    test('builds relative route names from browser URLs', () {
      final uri = Uri.parse(
        'https://example.github.io/CashOverFlow-flutter/accept-invite?token=abc',
      );
      expect(AppRouter.routeNameOf(uri), '/accept-invite?token=abc');
    });
  });

  group('ApiException.messageFrom', () {
    test('reads validation errors first', () {
      expect(
        ApiException.messageFrom({
          'title': 'One or more validation errors occurred.',
          'errors': {
            'Password': ['Password is too weak.'],
          },
        }),
        'Password is too weak.',
      );
    });

    test('falls back to message / error / title', () {
      expect(ApiException.messageFrom({'message': 'Nope'}), 'Nope');
      expect(ApiException.messageFrom({'error': 'Bad'}), 'Bad');
      expect(ApiException.messageFrom({'title': 'Title'}), 'Title');
      expect(ApiException.messageFrom(null), isNull);
    });
  });

  group('Models', () {
    test('DemoRequest tolerates numeric ids and normalizes status', () {
      final request = DemoRequest.fromJson({
        'id': 42,
        'companyName': 'Acme',
        'companyEmail': 'a@acme.com',
        'phoneNumber': 201001234567,
        'submittedAt': '2026-09-02T10:00:00Z',
        'status': 'PENDING',
      });
      expect(request.id, '42');
      expect(request.phoneNumber, '201001234567');
      expect(request.submissionDate, '2026-09-02');
      expect(request.status, 'Pending');
    });

    test('CurrentUser derives display role and permissions', () {
      final owner = CurrentUser.fromJson({'role': 'Owner', 'companyId': 7});
      expect(owner.isOwner, isTrue);
      expect(owner.companyId, '7');

      final member = CurrentUser.fromJson({'jobTitle': 'Analyst'});
      expect(member.displayRole, 'Analyst');
      expect(member.isOwner, isFalse);
      expect(CurrentUser.fromJson(const {}).displayRole, 'Member');
    });

    test('CashForecastData skips malformed rows instead of crashing', () {
      final data = CashForecastData.fromJson({
        'startCashOnHand': 100,
        'minCashBuffer': 50,
        'dailyForecast': [
          {'date': '2026-09-01', 'expectedCash': 100},
          {'date': 'not a date', 'expectedCash': 90},
          'garbage',
        ],
      });
      expect(data.dailyForecast, hasLength(1));
      expect(data.dailyForecast.first.pessimisticCash, 100);
      expect(data.horizonDays, 30);
    });
  });
}
