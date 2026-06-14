import 'package:flutter_test/flutter_test.dart';
import 'package:vistor_ai_mobile/shared/models/user.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';
import 'package:vistor_ai_mobile/shared/models/media.dart';
import 'package:vistor_ai_mobile/shared/models/report.dart';

void main() {
  group('User Model', () {
    test('should parse from JSON', () {
      final json = {
        'id': '1',
        'email': 'test@vistor.ai',
        'name': 'Test User',
        'role': 'inspector',
        'isActive': true,
        'created_at': '2026-06-02T10:00:00Z',
      };
      final user = User.fromJson(json);
      expect(user.id, '1');
      expect(user.role, UserRole.inspector);
    });
  });

  group('Inspection Model', () {
    test('should parse from JSON', () {
      final json = {
        'id': '101',
        'inspector_id': '1',
        'title': 'Rachadura estrutural',
        'category': 'civil',
        'location': {
          'lat': -23.5505,
          'lon': -46.6333,
        },
        'status': 'open',
        'created_at': '2026-06-02T10:00:00Z',
      };
      final inspection = Inspection.fromJson(json);
      expect(inspection.id, '101');
      expect(inspection.title, 'Rachadura estrutural');
      expect(inspection.status, InspectionStatus.open);
    });
  });

  group('Media Model', () {
    test('should parse from JSON', () {
      final json = {
        'id': '201',
        'inspection_id': '101',
        'type': 'photo',
        'minio_key': 'path/to/photo.jpg',
        'mime_type': 'image/jpeg',
        'size_bytes': 1024,
        'created_at': '2026-06-02T10:05:00Z',
      };
      final media = Media.fromJson(json);
      expect(media.id, '201');
      expect(media.type, MediaType.photo);
    });
  });

  group('Report Model', () {
    test('should parse from JSON', () {
      final json = {
        'id': '301',
        'inspection_id': '101',
        'generated_by': '1',
        'minio_key': 'path/to/report.pdf',
        'sha256': 'abc123hash',
        'created_at': '2026-06-02T10:10:00Z',
      };
      final report = Report.fromJson(json);
      expect(report.id, '301');
      expect(report.sha256, 'abc123hash');
    });
  });
}
