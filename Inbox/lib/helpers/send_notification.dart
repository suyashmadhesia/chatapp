import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class SendNotification{


List <String> topics =['/topics/APP'];
final fcm = FirebaseMessaging();

/*
collapse key
List of topic suscribed
sendNotification function
suscribing to a topic function
unsuscribing to a topic
no of topic to suscribing topic 
1> message from individual
2> message from a group
3> friends notification
4> group notification
5> accept notification // common to all users every body going to suscribe it ;
*/

Future<void> sendNotification(
     notificationTitle, sendersUserId, receiversUserId, message, notificationType, {bool isMuted, String topic}) async {
    // debugPrint('token : $token');

    final data = {
      "notification": {
        "body": message,
        "title": notificationTitle,
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "type": notificationType,
        "sendersUserId": sendersUserId,
        "receiversUserId" : receiversUserId,
        "isMuted" : isMuted,
      },
      "to": topic == null || topic.isEmpty ? "/topics/APP" : topic,
      "collapse_key": notificationType,
    };
    print(topic);
    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAdFdVbjo:APA91bGYkVTkUUKVcOk5O5jz2WZAwm8d1losRaJVEYKF5yspBahEWf-2oMhrnyWhi5pOumnSB0k8Lkb24ibUyawsYhD-P2H6gDUMOgflpQonYMKx9Ov6JmqbtY2uylIo2Moo4-9XbzfV'
    };

    BaseOptions options = new BaseOptions(
      connectTimeout: 5000,
      receiveTimeout: 3000,
      headers: headers,
    );

    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    try {
      final response = await Dio(options).post(postUrl, data: data);

      if (response.statusCode == 200) {
        print('message sent');
      } else {
        print('notification sending failed');
        // on failure do sth
      }
    } catch (e) {
      // debugPrint('exception $e');
    }print('notification send');
  }

  topicToSuscribe(String topicName) async{
    await fcm.subscribeToTopic(topicName);
  }

  topicToUnsuscribe(String topicName){
    fcm.unsubscribeFromTopic(topicName);
  }

}