# Event Interaction Guide

This guide explains how to interact with events in the weekly planner, including editing details and deleting events.

## Overview

Events in the weekly planner now have enhanced interaction capabilities:

1. **Edit Events**: Tap any event to open the detailed editor
2. **Delete Events**: Use the delete button with confirmation
3. **Preview Events**: Long-press to see event details
4. **Visual Indicators**: Clear visual cues for interaction

## Event Interaction Features

### Edit Events (Tap)

- **How to**: Simply tap on any event
- **What opens**: `EventDetailEditor` with full editing capabilities
- **Features**:
  - Edit title, subtitle, day, time, duration
  - Change color
  - Add detailed lesson plans using rich text editor
  - Save changes back to the event

### Delete Events (Delete Button)

- **How to**: Tap the red "X" button on any event
- **Confirmation**: Shows confirmation dialog before deleting
- **Safety**: Prevents accidental deletions
- **Visual**: Red button with clear delete icon

### Preview Events (Long Press)

- **How to**: Long-press any event
- **What shows**: Quick preview dialog with event details
- **Options**: View details or edit from preview

## Visual Indicators

### Edit Indicator

- **Edit Icon**: Small edit icon (✏️) appears on all events
- **Clickable Area**: Entire event area is clickable
- **Visual Feedback**: Events respond to touch

### Delete Button

- **Location**: Top-right corner of each event
- **Style**: Red circular button with "X" icon
- **Size**: 24x24 pixels for easy tapping
- **Color**: Red background with white border

### Details Indicator

- **When shown**: Only appears if event has details/lesson plan
- **Icon**: Description icon (📄) with "Has details" text
- **Purpose**: Indicates events with rich content

## Event Detail Editor

### What You Can Edit

1. **Basic Info**:

   - Title (required)
   - Subtitle (optional)
   - Day selection
   - Start time
   - Duration
   - Color

2. **Rich Details**:
   - Lesson plans
   - Notes
   - Instructions
   - Any formatted text

### Rich Text Editor Features

- **Bold Text**: Make important points stand out
- **Italic Text**: Emphasize key concepts
- **Bullet Points**: Create organized lists
- **Numbered Lists**: Step-by-step instructions
- **Plain Text**: Simple note-taking

### Saving Changes

- **Auto-save**: Changes are saved immediately
- **Validation**: Required fields are checked
- **Navigation**: Return to week view after saving

## Step-by-Step Guides

### Editing an Event

1. **Tap Event**

   - Tap any event in the week view
   - EventDetailEditor opens

2. **Edit Information**

   - Modify title, subtitle, schedule
   - Change color if needed
   - Add or edit lesson details

3. **Add Lesson Plan**

   - Use the rich text editor
   - Format text as needed
   - Add bullet points or numbered lists

4. **Save Changes**
   - Tap save button or use app bar save icon
   - Return to week view with updated event

### Deleting an Event

1. **Find Delete Button**

   - Look for red "X" in top-right corner
   - Button is clearly visible on all events

2. **Tap Delete Button**

   - Confirmation dialog appears
   - Shows event title for confirmation

3. **Confirm Deletion**

   - Tap "Delete" to confirm
   - Or "Cancel" to keep event

4. **Event Removed**
   - Event disappears from week view
   - Layout automatically adjusts

### Adding Event Details

1. **Open Event Editor**

   - Tap event to edit

2. **Scroll to Details Section**

   - Find "Event Details" section
   - Rich text editor is available

3. **Add Content**

   - Type lesson plans
   - Use formatting tools
   - Add bullet points or lists

4. **Save and View**
   - Save changes
   - Event shows "Has details" indicator

## Best Practices

### Event Editing

1. **Use Descriptive Titles**: Make events easy to identify
2. **Add Subtitles**: Provide additional context
3. **Color Code**: Use consistent colors for related activities
4. **Detailed Notes**: Add lesson plans and instructions

### Event Deletion

1. **Confirm Before Deleting**: Always check the confirmation dialog
2. **Backup Important Info**: Copy details before deleting if needed
3. **Use Preview**: Long-press to preview before editing/deleting

### Rich Text Usage

1. **Structure Content**: Use bullet points for lists
2. **Highlight Key Points**: Use bold for important information
3. **Keep It Organized**: Use consistent formatting
4. **Be Concise**: Focus on essential information

## Troubleshooting

### Edit Issues

1. **Event not opening**: Make sure you're tapping the event area, not the delete button
2. **Changes not saving**: Check that required fields are filled
3. **Editor not loading**: Ensure EventDetailEditor file exists

### Delete Issues

1. **Delete button not working**: Make sure you're tapping the red "X" button
2. **Confirmation not showing**: Check for dialog overlays
3. **Event not removed**: Verify deletion was confirmed

### Visual Issues

1. **Icons not showing**: Check if icons are properly imported
2. **Colors not updating**: Ensure color changes are saved
3. **Layout problems**: Events automatically reorganize after changes

## Code Implementation

### Delete Button

```dart
InkWell(
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(onPressed: () => _deleteEvent(e), child: Text('Delete')),
        ],
      ),
    );
  },
  child: Container(
    decoration: BoxDecoration(
      color: Colors.red.shade100,
      shape: BoxShape.circle,
    ),
    child: Icon(Icons.close, color: Colors.red.shade700),
  ),
)
```

### Edit Functionality

```dart
GestureDetector(
  onTap: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailEditor(event: e)),
    );
    setState(() => _computeLayouts());
  },
  child: Container(
    // Event display
  ),
)
```

### Visual Indicators

```dart
// Edit icon
Icon(Icons.edit, size: 12, color: Colors.white70)

// Details indicator
if (e.body.isNotEmpty) ...[
  Icon(Icons.description, size: 10, color: Colors.white60),
  Text('Has details', style: TextStyle(color: Colors.white60)),
]
```

## Advanced Features

### Future Enhancements

1. **Undo/Redo**: Track edit and delete operations
2. **Bulk Operations**: Edit or delete multiple events
3. **Templates**: Save common event configurations
4. **Export Details**: Share lesson plans and notes
5. **Collaboration**: Multi-user editing capabilities

### Integration Possibilities

1. **Calendar Sync**: Export to external calendars
2. **Document Attachments**: Link to external files
3. **Reminders**: Set notifications for events
4. **Progress Tracking**: Mark events as completed

---

This comprehensive interaction system provides intuitive and powerful event management capabilities for your teacher planner!
