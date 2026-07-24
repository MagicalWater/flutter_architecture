/// App 對本機網路介面／route 可用性的最小 typed 表達。
///
/// [online] 只代表至少存在可用介面，不保證 DNS、TLS、gateway 或
/// backend request 一定成功。
enum ConnectivityState { unknown, offline, online }
