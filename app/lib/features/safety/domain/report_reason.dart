/// Debe coincidir con el enum `report_reason` del SQL.
enum ReportReason {
  fakeProfile('fake_profile'),
  inappropriateContent('inappropriate_content'),
  harassment('harassment'),
  underage('underage'),
  spam('spam'),
  other('other');

  const ReportReason(this.dbValue);
  final String dbValue;
}
