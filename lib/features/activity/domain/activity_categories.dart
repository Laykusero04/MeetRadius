/// Stored in Firestore as `activities.category`. Host picker and feed chips use the same strings.
const List<String> kActivityCategoryValues = [
  'Sports',
  'Coffee',
  'Social',
  'Outdoor',
  'Gym',
  'Study',
  'Food',
  'Music',
  'Other',
];

/// Feed chip row: first chip is All; rest match [kActivityCategoryValues] in order.
const List<String> kFeedCategoryLabels = [
  'All',
  ...kActivityCategoryValues,
];
