import 'dart:io';

import 'ReplyBase.dart';

class AuthenticateReply extends ReplyBase
{
  AuthenticateReply(ReplyStatus status, this.authenticationCookie) : super(status);

  final Cookie authenticationCookie;
}