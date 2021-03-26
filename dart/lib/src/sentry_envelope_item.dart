import 'dart:convert';

import 'sentry_item_type.dart';
import 'protocol/sentry_event.dart';
import 'sentry_envelope_item_header.dart';

class SentryEnvelopeItem {
  SentryEnvelopeItem(this.header, this.data);

  final SentryEnvelopeItemHeader header;
  final List<int> data;

  // TODO(denis): Test formatting...
  static SentryEnvelopeItem fromEvent(SentryEvent event) {
    final jsonEncoded = jsonEncode(event.toJson());
    final data = utf8.encode(jsonEncoded);  
    return SentryEnvelopeItem(
      SentryEnvelopeItemHeader(SentryItemType.event, data.length),
      data
    );
  }

  String serialize() {
    return '';
  }
}
