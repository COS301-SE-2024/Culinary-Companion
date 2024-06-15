import 'package:flutter/material.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([], customMocks: [
  MockSpec<NavigatorObserver>(
    as: #MockNavigatorObserver,
    onMissingStub: OnMissingStub.returnDefault,
  )
])


// Remove this class
// class MockNavigatorObserver extends MockNavigatorObserverMixin implements NavigatorObserver {}

// Keep this mixin
mixin MockNavigatorObserverMixin on Mock, NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      super.noSuchMethod(
        Invocation.method(#didPush, [route, previousRoute]),
        returnValueForMissingStub: null,
      );
}