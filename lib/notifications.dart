import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
    static NotificationHelper _singleton;

    static Future<NotificationHelper> instance() async {
        if (_singleton == null) {
            _singleton = NotificationHelper();
            await _singleton._init();
        }
        return _singleton;
    }

    FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

    Future<void> _init() async {
        final initSettingsAndroid = AndroidInitializationSettings('app_icon');
        final initSettings = InitializationSettings(android: initSettingsAndroid);

        await _plugin.initialize(initSettings);
    }

    String _format(Duration time) {
        final minutes = time.inMinutes.toString().padLeft(2, '0');
        final seconds = (time.inSeconds % 60).toString().padLeft(2, '0');
        return '$minutes:$seconds';
    }

    Future<void> showTask(String name, Duration time) async {
        await _plugin.show(
            0, name, '${_format(time)} remaining',
            NotificationDetails(android: AndroidNotificationDetails(
                'daily_task_progress', 'Daily Task Progress', '',
                importance: Importance.defaultImportance,
                enableVibration: false,
                showWhen: false,
                ongoing: true,
                autoCancel: false,
            )),
        );
    }

    Future<void> pauseTask() async {
        await _plugin.cancel(0);
    }

    Future<void> endTask(String name) async {
        await _plugin.cancel(0);
        await _plugin.show(
            1, name, 'Finished!',
            NotificationDetails(android: AndroidNotificationDetails(
                'daily_task_finished', 'Daily Task Finished', '',
                importance: Importance.max,
                showWhen: true,
                ongoing: false,
                autoCancel: true,
            )),
        );
    }
}
