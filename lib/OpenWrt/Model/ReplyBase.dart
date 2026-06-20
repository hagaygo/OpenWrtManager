enum ReplyStatus
{
  Ok,
  Forbidden,
  UnexpectedRedirect,
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