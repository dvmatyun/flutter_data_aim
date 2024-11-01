import '../domain/exception_aim.dart';

class ApiQyreException implements Exception, IExceptionAim {
  const ApiQyreException({this.code = 'unknown', this.message = 'unknown', this.title = 'unknown'});

  @override
  final String code;

  @override
  final String message;

  @override
  final String title;
}

class TranslatedExceptionAim extends ApiQyreException {
  TranslatedExceptionAim({super.title, super.message}) : super();
}

class UnknownApiExceptionAim extends ApiQyreException {
  UnknownApiExceptionAim({super.message}) : super();

  @override
  String get title => 'Unknown api error';
}

class ConnectionQyreException extends ApiQyreException {
  ConnectionQyreException({super.message}) : super();

  @override
  String get title => 'Connection error';
}

class ServerQyreApiException extends ApiQyreException {
  ServerQyreApiException({required super.title, super.message}) : super();
}

class NotFoundQyreApiException extends ApiQyreException {
  NotFoundQyreApiException({
    super.title = 'Not found',
    super.message = 'Entity not found',
    super.code = 'not_found',
  }) : super();
}

class QyreApiCodeException extends ApiQyreException {
  QyreApiCodeException({super.code, super.message}) : super();
}

// server code = 'update_required'
class ClientVersionUpdateRequiredException implements IExceptionAim {
  ClientVersionUpdateRequiredException({this.title = 'Update required', this.message = ''}) : super();

  @override
  String get code => '601';

  @override
  final String title;
  @override
  final String message;
}
