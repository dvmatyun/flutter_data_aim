import '../models/analytics_event_dto.dart';

// ignore: one_member_abstracts
abstract class IAnalyticsDataSource {
  Future<bool> sendData(List<AnalyticsEventDto> events);
}

class AnalyticsDataSource implements IAnalyticsDataSource {
  const AnalyticsDataSource();

  @override
  Future<bool> sendData(List<AnalyticsEventDto> events) async {
    //final json = await compute(jsonEncode, events);
    /*
    await _wsSource.singleRequest(SocketRequest.mirror(
      requestMessage: MessageToServer.duo(
        host: ServerTopics.gameMenu.value,
        topic1: 'analytics',
        data: json,
      ),
    ));
    */
    return true;
  }
}
