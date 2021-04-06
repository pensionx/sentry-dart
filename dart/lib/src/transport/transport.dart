import 'dart:async';

import '../sentry_envelope.dart';
import '../protocol.dart';

/// A transport is in charge of sending the events/envelope either via http
/// or caching in the disk.
abstract class Transport {
  Future<SentryId?> sendSentryEvent(SentryEvent event);
  Future<SentryId?> sendSentryEnvelope(SentryEnvelope envelope);
}
