# Drag & Drop Event Management Guide

This guide explains the new simplified event creation and drag-and-drop functionality in your teacher planner app.

## Overview

The app now features a streamlined workflow:

1. **Quick Event Creation**: Create events with just title, subtitle, and color
2. **Drag & Drop Placement**: Position events anywhere in the week view
3. **Detailed Editing**: Click events to edit all properties including scheduling and details
4. **Time Constraints**: Events are constrained to valid time ranges

## New Workflow

### 1. Creating Events

- Tap the "+" button to open the simplified event creation form
- Enter only the essential information:
  - **Title** (required)
  - **Subtitle** (optional)
  - **Color** (choose from expanded palette)
- New events are automatically placed at 9 AM on Wednesday
- You can then drag them to any desired position

### 2. Drag & Drop Functionality

Events can be dragged and resized in multiple ways:

#### **Vertical Dragging (Time)**

- Drag up/down to change start time
- Events are constrained between 6 AM and 6 PM
- Minimum duration: 1 hour

#### **Horizontal Dragging (Days)**

- Drag left/right to change days
- Events can span across multiple days for recurring events
- Perfect for lunch, recess, or other daily activities

#### **Resizing**

- **Top/Bottom handles**: Change duration
- **Left/Right handles**: Extend across days
- All changes respect time constraints

### 3. Detailed Editing

- **Tap any event** to open the full editor
- Edit all properties:
  - Event information (title, subtitle)
  - Schedule (day, start time, duration)
  - Color
  - Detailed notes/lesson plans

## Features

### Time Constraints

- **Floor**: 6:00 AM (startHour = 6)
- **Ceiling**: 6:00 PM (endHour = 18)
- Events cannot be dragged outside these bounds
- Duration is automatically adjusted to fit within constraints

### Multi-Day Events

- Perfect for recurring activities like:
  - **Lunch**: 12:00-13:00 across all days
  - **Recess**: 10:30-11:00 across all days
  - **Assembly**: 8:00-9:00 on specific days

### Visual Feedback

- Events show:
  - Title and subtitle
  - Time range
  - Color-coded for easy identification
- Drag handles are visible when hovering
- Real-time position updates

## Code Implementation

### Event Creation

```dart
// Simplified event creation
EventBlock(
  day: 'Mon', // Will be set when placed
  subject: 'Math Class',
  subtitle: 'Grade 5',
  color: Colors.blue,
  startHour: 8, // Will be set when placed
  duration: 1,
)
```

### Drag & Drop Constraints

```dart
// Time constraints
final startHour = 6; // Floor time
final endHour = 18; // Ceiling time

// Position calculation
final newStartHour = _getHourFromY(r.top, slotH);
final newDuration = (r.height / slotH).round().clamp(1, endHour - startHour);
final newDay = _getDayFromX(r.left, colW);
```

### Event Editor Integration

```dart
// Open detailed editor
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => EventDetailEditor(event: event),
  ),
);
```

## Use Cases

### 1. Quick Lesson Planning

1. Create event with just title and color
2. Drag to correct time slot
3. Click to add detailed lesson plan

### 2. Recurring Activities

1. Create lunch/recess event
2. Drag horizontally to span multiple days
3. Perfect for daily activities

### 3. Flexible Scheduling

1. Create placeholder events
2. Drag and resize as needed
3. Add details later

## Best Practices

### Event Creation

1. **Start Simple**: Use basic info for quick creation
2. **Color Coding**: Use consistent colors for similar activities
3. **Descriptive Titles**: Make events easy to identify

### Drag & Drop

1. **Plan Ahead**: Consider time constraints when dragging
2. **Use Multi-Day**: Extend events horizontally for recurring activities
3. **Resize Carefully**: Ensure events fit within time bounds

### Organization

1. **Group Similar Events**: Use same colors for related activities
2. **Clear Labels**: Make titles descriptive and clear
3. **Regular Updates**: Edit details as plans change

## Advanced Features

### Custom Time Ranges

You can modify the time constraints:

```dart
final int startHour = 6; // Change to 7 for 7 AM start
final int endHour = 18; // Change to 20 for 8 PM end
```

### Event Templates

Create common event types:

```dart
EventBlock createLunchEvent() {
  return EventBlock(
    day: 'Mon',
    subject: 'Lunch',
    subtitle: 'All Grades',
    color: Colors.orange,
    startHour: 12,
    duration: 1,
  );
}
```

### Auto-Placement

Smart placement for new events:

```dart
// Find next available slot
String findNextAvailableDay() {
  // Implementation for finding free time slots
}
```

## Troubleshooting

### Common Issues

1. **Events not dragging**: Ensure you're using the correct drag handles
2. **Time constraints**: Events cannot go outside 6 AM - 6 PM
3. **Layout issues**: Events automatically reorganize when overlapping

### Performance Tips

1. **Limit event count**: Too many events may affect performance
2. **Efficient updates**: Use setState() only when necessary
3. **Memory management**: Dispose of controllers properly

## Future Enhancements

### Potential Improvements

1. **Snap to Grid**: Snap events to 15-minute intervals
2. **Copy/Paste**: Duplicate events across days
3. **Undo/Redo**: Track changes and allow reversal
4. **Event Categories**: Group events by type
5. **Export/Import**: Save and load schedules

### Advanced Drag Features

1. **Multi-Select**: Drag multiple events at once
2. **Smart Suggestions**: Suggest optimal placement
3. **Conflict Detection**: Warn about overlapping events
4. **Auto-Scheduling**: Automatically place events in free slots

---

This new drag-and-drop system provides a much more intuitive and flexible way to manage your teacher planner. The simplified creation process combined with powerful editing capabilities makes it easy to create and organize your schedule efficiently!
