// flutter test --dart-define=IS_TEST=true
const bool isTesting = bool.fromEnvironment('IS_TEST', defaultValue: false);
const String syncTestToken = String.fromEnvironment('SYNC_TEST_TOKEN');
const String feedbackToken = String.fromEnvironment('FEEDBACK_TOKEN');