/// App 目前看到的網路連線狀態。
///
/// [online] 只代表裝置目前有可用網路介面，不保證 DNS、TLS 或後端 request 一定成功。
enum ConnectivityState {
  /// App 還沒完成第一次網路狀態判定。
  unknown,

  /// 目前沒有可用網路介面。
  offline,

  /// 目前至少有一個可用網路介面。
  online,
}
