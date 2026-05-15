/// Device-local user preferences (notifications, discovery).
final class UserSettings {
  const UserSettings({
    this.notifyActivity = true,
    this.notifyChat = true,
    this.notifyLiveNearby = true,
    this.useGpsForDiscovery = true,
    this.discoveryAnchorEpoch = 0,
  });

  final bool notifyActivity;
  final bool notifyChat;
  final bool notifyLiveNearby;
  final bool useGpsForDiscovery;

  /// Bumped when the user refreshes discovery location (feed/map re-resolve).
  final int discoveryAnchorEpoch;

  static const defaults = UserSettings();

  UserSettings copyWith({
    bool? notifyActivity,
    bool? notifyChat,
    bool? notifyLiveNearby,
    bool? useGpsForDiscovery,
    int? discoveryAnchorEpoch,
  }) {
    return UserSettings(
      notifyActivity: notifyActivity ?? this.notifyActivity,
      notifyChat: notifyChat ?? this.notifyChat,
      notifyLiveNearby: notifyLiveNearby ?? this.notifyLiveNearby,
      useGpsForDiscovery: useGpsForDiscovery ?? this.useGpsForDiscovery,
      discoveryAnchorEpoch:
          discoveryAnchorEpoch ?? this.discoveryAnchorEpoch,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettings &&
          notifyActivity == other.notifyActivity &&
          notifyChat == other.notifyChat &&
          notifyLiveNearby == other.notifyLiveNearby &&
          useGpsForDiscovery == other.useGpsForDiscovery &&
          discoveryAnchorEpoch == other.discoveryAnchorEpoch;

  @override
  int get hashCode => Object.hash(
        notifyActivity,
        notifyChat,
        notifyLiveNearby,
        useGpsForDiscovery,
        discoveryAnchorEpoch,
      );
}
