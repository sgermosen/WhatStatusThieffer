import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class AppModel extends Model {
  // Variables
  bool showAds = true;
  bool addWatermark = true;
  bool isDarkThemeEnabled = false;
  bool isRewarded = false;
  int rewardedCounter = 0;
  Timer _timer;
  List<String> selectedStatusList = [];

  /// Create Singleton factory for [AppModel]
  static final AppModel _appModel = new AppModel._internal();
  factory AppModel() {
    return _appModel;
  }
  AppModel._internal();
  // End

  /// Disable show Ads when User Purchases - Remove Ads Subscription
  void disableShowAds() {
    this.showAds = false;
    notifyListeners();
    print('disableShowAds() -> success');
  }

  /// Disable show Ads when User Purchases - Remove Watermark Subscription
  void disableWatermark() {
    this.addWatermark = false;
    notifyListeners();
    print('disableWatermark() -> success');
  }

  void updateAppTheme(bool value) {
    this.isDarkThemeEnabled = value;
    notifyListeners();
    print('updateAppTheme() -> success');
  }

  void updateRewarded(bool boolVal, int min) {
    this.isRewarded = boolVal;
    this.rewardedCounter += min;
    notifyListeners();
    print('updateRewarded() -> success');
  }

  void rewardedTimer({@required VoidCallback onEndTimer}) {
    if (_timer != null) _timer.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (this.rewardedCounter > 0) {
        // Count down the rewarded minutes
        this.rewardedCounter--;
        notifyListeners();
      } else {
        this.isRewarded = false;
        notifyListeners();
        _timer.cancel();
        onEndTimer();
      }
    });
  }

  //TODO: this is not working well, but i can find the reason, so, Metan mano
  /// Select statuses for Bulk Belete
  void selectStatuses(String statusPath) {
    if (!selectedStatusList.contains(statusPath)) {
      selectedStatusList.add(statusPath);
      notifyListeners();
    } else {
      selectedStatusList.removeWhere((val) => val == statusPath);
      notifyListeners();
    }
  }

  /// Clear selected statuses
  void clearSeletedStatuses() {
    selectedStatusList.clear();
    notifyListeners();
  }
}
