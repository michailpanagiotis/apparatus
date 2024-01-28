
.key as $key
| .fields
| {
  key: $key,
  parent: .parent.key,
  resolution: .resolution.name,
  priority: .priority.name,
  assignee: (.assignee | { emailAddress, displayName }),
  status: .status.name,
  creator: (.creator | { emailAddress, displayName }),
  subtasks: (.subtasks | map(.key)),
  reporter: (.reporter | { emailAddress, displayName }),
  issuetype: .issuetype.name,
  project: .project.key,
  created,
  updated,
  summary,
}
