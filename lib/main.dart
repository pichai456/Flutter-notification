import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<dynamic> _firebaseMessagingBackgroundHandler(
    Map<String, dynamic> message,
) async {
      // Initialize the Firebase app
      await Firebase.initializeApp();
      print('onBackgroundMessage received: $message');
}

 Future<void> main() async { 
 WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Notification'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String message;
  String channelId = "1000";
  String channelName = "FLUTTER_NOTIFICATION_CHANNEL";
  String channelDescription = "FLUTTER_NOTIFICATION_CHANNEL_DETAIL";
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
          const DrawableResourceAndroidBitmap('flutter'),
          largeIcon: const DrawableResourceAndroidBitmap('flutter'),
          contentTitle: 'สวัสดีครับคุณ <b> User </b>',
          htmlFormatContentTitle: true,
          summaryText: 'สรุปข่าว <i> ข่าวสำคัญ </i>',
          htmlFormatSummaryText: true
          );

initState() {
    initFirebaseMessaging();
    super.initState();
  }

  void initFirebaseMessaging() {

    firebaseMessaging.configure(
      onBackgroundMessage: _firebaseMessagingBackgroundHandler,
     onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        Map mapNotification = message["notification"];
        String title = mapNotification["title"];
        String body = mapNotification["body"];
        sendNotification(title, body);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Token : $token");
    });

 
  }

  sendNotification(String title,String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('10000',
        'FLUTTER_NOTIFICATION_CHANNEL', 'FLUTTER_NOTIFICATION_CHANNEL_DETAIL',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: bigPictureStyleInformation,
      );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    
     var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,iOS: 
        iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        111,title, body, platformChannelSpecifics,
        payload: 'I just haven\'t Met You Yet');
  }

    Future<void> sendPushMessage() async {
        firebaseMessaging.getToken().then((String _token) async {
      assert(_token != null);
      if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }
    
    var st = constructFCMPayload(_token);
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
           'Authorization':'key=AAAAk7Nlaro:APA91bECgJxALkjT3UYZG3OaE_cf8iQ9IZyQuYzMbhxSt1ekSdAAYEO5p5rfyN0qPkBbNE5QTw0yYCN3heSvei9uMfrumwJqHOx8Lt3xczjM6UoE96tz2SzDdkcaUqQ6P354axQcxK4b',
        },
        body: st,
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
      print("Token : $_token");

    });
    }
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Your Notification App',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          sendPushMessage();
        },
        tooltip: 'Increment',
        child: Icon(Icons.notifications_active),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

int _messageCount = 0;
  String constructFCMPayload(String token) {
  _messageCount++;
  return jsonEncode({
    'to': token,
    'data': {
      'via': 'Firebase Cloud Messaging!!!',
      'count': _messageCount.toString(),
    },
    'notification': {
      'title': 'Hello Firebase Cloud Messaging!',
      'body': 'This notification (#$_messageCount) was created via FCM!',
    },
  });
}

