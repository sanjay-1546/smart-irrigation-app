class ConnectivityService {
  bool _offlineModeForced = false;

  bool get isOffline => _offlineModeForced;

  void setOfflineMode(bool offline) {
    _offlineModeForced = offline;
  }
}
