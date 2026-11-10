import 'package:flutter/services.dart';

const MethodChannel _channel = MethodChannel('flutter_screentime');

enum ScreenTimeAuthorizationStatus {
  notDetermined('notDetermined'),
  denied('denied'),
  approved('approved');

  const ScreenTimeAuthorizationStatus(this.platformValue);

  final String platformValue;

  static ScreenTimeAuthorizationStatus fromPlatformValue(String? value) {
    return values.firstWhere(
      (status) => status.platformValue == value,
      orElse: () => ScreenTimeAuthorizationStatus.notDetermined,
    );
  }
}

class ScreenTimeBlockScreenConfig {
  const ScreenTimeBlockScreenConfig({
    required this.title,
    required this.message,
    this.backgroundColorHex = '#111827',
    this.textColorHex = '#FFFFFF',
    this.primaryButtonLabel,
    this.secondaryButtonLabel,
  });

  final String title;
  final String message;
  final String backgroundColorHex;
  final String textColorHex;
  final String? primaryButtonLabel;
  final String? secondaryButtonLabel;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'title': title,
      'message': message,
      'backgroundColorHex': backgroundColorHex,
      'textColorHex': textColorHex,
      'primaryButtonLabel': primaryButtonLabel,
      'secondaryButtonLabel': secondaryButtonLabel,
    };
  }

  factory ScreenTimeBlockScreenConfig.fromMap(Map<Object?, Object?> map) {
    return ScreenTimeBlockScreenConfig(
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      backgroundColorHex: map['backgroundColorHex'] as String? ?? '#111827',
      textColorHex: map['textColorHex'] as String? ?? '#FFFFFF',
      primaryButtonLabel: map['primaryButtonLabel'] as String?,
      secondaryButtonLabel: map['secondaryButtonLabel'] as String?,
    );
  }
}

class SelectedAppsSummary {
  const SelectedAppsSummary({
    required this.applicationCount,
    required this.categoryCount,
  });

  final int applicationCount;
  final int categoryCount;

  factory SelectedAppsSummary.fromMap(Map<Object?, Object?> map) {
    return SelectedAppsSummary(
      applicationCount: (map['applicationCount'] as num?)?.toInt() ?? 0,
      categoryCount: (map['categoryCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class FlutterScreentime {
  const FlutterScreentime();

  Future<ScreenTimeAuthorizationStatus> checkAuthorization() async {
    final status = await _channel.invokeMethod<String>('checkAuthorization');
    return ScreenTimeAuthorizationStatus.fromPlatformValue(status);
  }

  Future<ScreenTimeAuthorizationStatus> requestAuthorization() async {
    final status = await _channel.invokeMethod<String>('requestAuthorization');
    return ScreenTimeAuthorizationStatus.fromPlatformValue(status);
  }

  Future<void> setSharedContainerId(String appGroupId) {
    return _channel.invokeMethod<void>('setSharedContainerId', appGroupId);
  }

  Future<void> configureBlockScreen(ScreenTimeBlockScreenConfig config) {
    return _channel.invokeMethod<void>('configureBlockScreen', config.toMap());
  }

  Future<void> setBlockedPackages(List<String> packageNames) {
    return _channel.invokeMethod<void>('setBlockedPackages', packageNames);
  }

  Future<SelectedAppsSummary> selectBlockedApps() async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'selectBlockedApps',
    );
    return SelectedAppsSummary.fromMap(result ?? const <Object?, Object?>{});
  }

  Future<void> startBlocking() {
    return _channel.invokeMethod<void>('startBlocking');
  }

  Future<void> stopBlocking() {
    return _channel.invokeMethod<void>('stopBlocking');
  }

  /// Léxi : affiche une notification (marche aussi en arrière-plan).
  Future<bool> lexiNotifier(int id, String titre, String texte) async {
    final ok = await _channel.invokeMethod<bool>(
        'lexiNotifier', {'id': id, 'titre': titre, 'texte': texte});
    return ok ?? false;
  }

  /// Léxi : les notifications sont-elles autorisées ?
  Future<bool> lexiNotificationsOk() async {
    return await _channel.invokeMethod<bool>('lexiNotificationsOk') ?? false;
  }

  /// Léxi : demande l'autorisation d'envoyer des notifications (Android 13+).
  Future<bool> lexiDemanderNotifications() async {
    return await _channel.invokeMethod<bool>('lexiDemanderNotifications') ??
        false;
  }

  /// Léxi : rappel quand on passe [minutes] minutes par jour sur une des
  /// applis [packages] (en dehors des heures de blocage).
  Future<bool> lexiVeille({
    required bool actif,
    int minutes = 15,
    List<String> packages = const [],
  }) async {
    return await _channel.invokeMethod<bool>('lexiVeille', {
          'actif': actif,
          'minutes': minutes,
          'packages': packages,
        }) ??
        false;
  }
}
