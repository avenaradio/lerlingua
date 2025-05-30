// flutter test --dart-define=IS_TEST=true
const bool isTesting = bool.fromEnvironment('IS_TEST', defaultValue: false);
const String syncTestToken = String.fromEnvironment('SYNC_TEST_TOKEN');
const String feedbackToken = String.fromEnvironment('FEEDBACK_TOKEN');
const String gitlabUrl = 'gitlab.iue.fh-kiel.de';
const String gitlabProjectId = '5990';