/** This script handles auto-populating of the Approved Resources sheet and notifications
  * to the slack channel #resources.
  * It is installed on the spreadsheet via Script Editor (Apps Script).
  *
  * This code is derived from https://github.com/markfguerra/google-forms-to-slack
  *
  * Version control on Apps Scripts is questionable at best so it's worth storing another
  * copy of the code here for transparency and manageability.
  */

var slackIncomingWebhookUrl = 'https://hooks.slack.com/services/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';
var postChannel = "#resources";
var messageFallback = "The attachment must be viewed as plain text.";

// In the Script Editor, run initialize() at least once to make your code execute on form submit
function initialize() {
  var triggers = ScriptApp.getProjectTriggers();
  for (var i in triggers) {
    ScriptApp.deleteTrigger(triggers[i]);
  }
  ScriptApp.newTrigger("submitValuesToSlack")
    .forSpreadsheet(SpreadsheetApp.getActiveSpreadsheet())
    .onFormSubmit()
    .create();

  ScriptApp.newTrigger("copyResourcesToApproved")
    .forSpreadsheet(SpreadsheetApp.getActiveSpreadsheet())
    .onFormSubmit()
    .create();
}

// The following method copies new response over to Approved Resource tab.
function copyResourcesToApproved(e) {
  // Copy only if "meets FTC standards is a yes"
  var guidelinesColumn = 4; // should be 2 for the real resources
  if(e.values[guidelinesColumn] != "Yes") {
    Logger.log("Resource does not meet standards: %s", e.values[guidelinesColumn])
    return;
  }

  // Maps original (form submission) column names to Approved Resources tab column names.
  // Note that not all resources are copied over.
  var columnMap = new Map([
    ["Timestamp", "timestamp"],
    ["Type of resource", "category"],
    ["Country", "country"],
    ["URL", "url"],
    ["Title", "name"],
    ["Description", "description"],
    ["State or province", "state"]
  ]);

  var destSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Approved Resources");
  var destColumns = getColumnNames(destSheet);
  var newRow = [];
  for(colName in e.namedValues) {
    if(!columnMap.has(colName)) {
       continue;
    }
    var destIndex = destColumns.indexOf(columnMap.get(colName));
    if (destIndex == -1) {
      continue;
    }
    newRow[destIndex] = e.namedValues[colName][0];
  }
  newRow[0] = 'approved_by_default';
  destSheet.appendRow(newRow);
}

// Constructs a brief slack message about the new resource submission.
function submitValuesToSlack(e) {
  var attachments = constructAttachments(e.values);

  var payload = {
    "channel": postChannel,
    "username": "Resource Form Submission",
    "icon_emoji": ":package:",
    "link_names": 1,
    "attachments": attachments
  };

  var options = {
    'method': 'post',
    'payload': JSON.stringify(payload)
  };

  var response = UrlFetchApp.fetch(slackIncomingWebhookUrl, options);
}

// Creates Slack message attachments which contain the data from the Google Form
// submission, which is passed in as a parameter
// https://api.slack.com/docs/message-attachments
var messagePretext = [
  "New resource submitted.",
  "<https://github.com/flattenthecurve/guide/wiki/Processes|See here> for the process documentation. ",
  "If the resource meets FTC criteria it should be automatically copied over to " +
  "<https://docs.google.com/spreadsheets/d/1QSQgxceR8BL03qsR-GY8bw4tsdsx30kovU7wVXPUcxo/edit#gid=650653420|Approved Resources tab> " +
  "and will be picked up by import_resources.py script next time it is run."
].join("\n");
var constructAttachments = function(values) {
  var fields = makeFields(values);

  var attachments = [{
    "fallback" : messageFallback,
    "pretext" : messagePretext,
    "mrkdwn_in" : ["pretext"],
    "color" :  "#0000DD",
    "fields" : fields
  }]

  return attachments;
}

// Creates an array of Slack fields containing the questions and answers
var makeFields = function(values) {
  var fields = [];

  // Possibly just use first sheet here: SpreadsheetApp.getSheets()[0]
  var columnNames = getColumnNames(SpreadsheetApp.getActiveSheet());

  for (var i = 0; i < columnNames.length && i < values.length; i++) {
    var colName = columnNames[i];
    var val = values[i];
    fields.push(makeField(colName, val));
  }

  return fields;
}

// Creates a Slack field for your message
// https://api.slack.com/docs/message-attachments#fields
var makeField = function(question, answer) {
  var field = {
    "title" : question,
    "value" : answer,
    "short" : false
  };
  return field;
}

// Extracts the column names from the first row of the spreadsheet
var getColumnNames = function(sheet) {
  // Get the header row using A1 notation
  var headerRow = sheet.getRange("1:1");

  // Extract the values from it
  var headerRowValues = headerRow.getValues()[0];

  return headerRowValues;
}

