enum ReplyStatus
{
  Ok,
  Forbidden,
  Timeout,
  Error,
  HandshakeError,
  NotFound
}

abstract class ReplyBase
{
  ReplyBase(this.status);

  final ReplyStatus status;  
}