import '/screens/forms/model/server_submission.dart';

class FetchSubmissionsResponse {
  List<ServerSubmission> submissionList;
  List<String> deletedSubmissionList;

  FetchSubmissionsResponse({
    required this.submissionList,
    required this.deletedSubmissionList,
  });

  factory FetchSubmissionsResponse.fromJson(Map<String, dynamic> json) {
    List<ServerSubmission> submissions = <ServerSubmission>[];
    if (json['submissions'] != null) {
      json['submissions'].forEach((v) {
        submissions.add(ServerSubmission.fromJson(v));
      });
    }
    List<String> deletedSubmissions = <String>[];
    if (json['deletedEvents'] != null) {
      deletedSubmissions =
          (json['deletedEvents'] as List<dynamic>).cast<String>();
    }
    return FetchSubmissionsResponse(
      submissionList: submissions,
      deletedSubmissionList: deletedSubmissions,
    );
  }

  Map<String, dynamic> toJson() => {
        'submissions': submissionList,
        'deletedEvents': deletedSubmissionList,
      };
}
