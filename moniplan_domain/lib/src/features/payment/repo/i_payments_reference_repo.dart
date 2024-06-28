import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_domain/src/_index.dart';

abstract interface class IPaymentsReferenceRepo {
  /// Получение списка деталей платежей
  Future<List<PaymentDetails>> getPaymentsDetailsReference();

  /// Получение списка тегов исходя из деталей платежей
  Future<Set<String>> getAvailableTags();

  Future<Set<String>> getAllTags();
}
