import 'package:custom_data/exceptions/domain/exception_aim.dart';

class ClientException implements IExceptionAim {
  const ClientException({this.code = '0', this.message = 'unknown', this.title = 'unknown'});

  @override
  final String code;

  @override
  final String message;

  @override
  final String title;
}
