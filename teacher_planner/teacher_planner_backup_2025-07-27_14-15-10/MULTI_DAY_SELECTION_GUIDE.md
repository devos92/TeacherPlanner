# Multi-Day Event Selection Guide

This guide explains the new multi-day selection feature that allows you to create events across multiple days efficiently.

## Overview

The new system replaces the complex drag-and-drop functionality with a more reliable and intuitive approach:

1. **Multi-Day Selection**: Choose which days to create events for
2. **Batch Creation**: Create multiple events at once
3. **Visual Feedback**: See exactly how many events will be created
4. **Flexible Scheduling**: Set time and duration for all selected days

## How It Works

### 1. Creating Events

- Tap the "+" button to open the event creation form
- Enter event information:
  - **Title** (required)
  - **Subtitle** (optional)
  - **Color** (choose from expanded palette)
- Select days using the filter chips
- Set start time and duration
- Create multiple events at once

### 2. Day Selection

- **Individual Selection**: Tap each day chip to select/deselect
- **Select All**: Quick button to select all days
- **Clear All**: Quick button to deselect all days
- **Visual Feedback**: Selected days show in event color
- **Count Display**: Shows how many events will be created

### 3. Time and Duration

- **Start Time**: Choose from 00:00 to 23:00
- **Duration**: 1 to 8 hours
- **Applied to All**: Same time/duration for all selected days
- **End Time Display**: Shows calculated end time

## Features

### Multi-Day Selection

```dart
Map<String, bool> _selectedDays = {
  'Mon': false,
  'Tue': false,
  'Wed': false,
  'Thu': false,
  'Fri': false,
};
```

### Batch Event Creation

```dart
// Create multiple events for selected days
final events = selectedDays.map((day) => EventBlock(
  day: day,
  subject: _subject,
  subtitle: _subtitle,
  body: '',
  color: _color,
  startHour: _startHour,
  duration: _duration,
)).toList();
```

### Visual Feedback

- **Filter Chips**: Show selected state with event color
- **Info Box**: Displays count of events to be created
- **Color Coding**: Selected chips match event color
- **Real-time Updates**: Changes reflect immediately

## Use Cases

### 1. Recurring Activities

Perfect for daily activities like:

- **Lunch**: 12:00-13:00 across all days
- **Recess**: 10:30-11:00 across all days
- **Assembly**: 8:00-9:00 on specific days

### 2. Weekly Schedule

Create your entire week at once:

- **Math Class**: Mon, Wed, Fri at 9:00 AM
- **Science Lab**: Tue, Thu at 2:00 PM
- **Art Class**: Mon, Wed at 3:00 PM

### 3. Flexible Planning

- **Select Multiple Days**: Choose any combination
- **Same Time Slots**: Consistent scheduling
- **Quick Creation**: No need to create each day separately

## Step-by-Step Guide

### Creating a Multi-Day Event

1. **Open Event Creator**

   - Tap the "+" button
   - Form opens with default settings

2. **Enter Basic Info**

   - Type event title (e.g., "Math Class")
   - Add optional subtitle (e.g., "Grade 5")
   - Choose a color

3. **Select Days**

   - Tap day chips to select (Mon, Tue, Wed, etc.)
   - Use "Select All" for every day
   - Use "Clear All" to start over
   - Watch the count update

4. **Set Schedule**

   - Choose start time (e.g., 9:00 AM)
   - Set duration (e.g., 1 hour)
   - See end time calculated automatically

5. **Create Events**
   - Tap "Create Events"
   - Multiple events appear in week view
   - Each event can be edited individually

### Editing Events

1. **Individual Editing**

   - Tap any event to open detailed editor
   - Change title, subtitle, time, duration
   - Add detailed notes or lesson plans

2. **Quick Preview**

   - Long-press event for quick preview
   - See basic info without opening editor

3. **Delete Events**
   - Tap the "X" button on any event
   - Event is removed immediately

## Code Examples

### Day Selection Logic

```dart
void _toggleDay(String day) {
  setState(() {
    _selectedDays[day] = !_selectedDays[day]!;
  });
}

void _selectAllDays() {
  setState(() {
    _selectedDays.updateAll((key, value) => true);
  });
}

void _clearAllDays() {
  setState(() {
    _selectedDays.updateAll((key, value) => false);
  });
}
```

### Event Creation

```dart
// Get selected days
final selectedDays = _selectedDays.entries
    .where((entry) => entry.value)
    .map((entry) => entry.key)
    .toList();

// Create events for each selected day
final events = selectedDays.map((day) => EventBlock(
  day: day,
  subject: _subject,
  subtitle: _subtitle,
  body: '',
  color: _color,
  startHour: _startHour,
  duration: _duration,
)).toList();
```

### Visual Feedback

```dart
// Show count of events to be created
Text(
  'Will create $selectedDaysCount event${selectedDaysCount > 1 ? 's' : ''} for selected day${selectedDaysCount > 1 ? 's' : ''}',
  style: TextStyle(color: _color.shade700),
)
```

## Best Practices

### Day Selection

1. **Plan Ahead**: Think about which days need the event
2. **Use Select All**: For truly daily activities
3. **Be Specific**: Only select days that actually need the event
4. **Check Count**: Verify the number of events before creating

### Event Creation

1. **Descriptive Titles**: Make events easy to identify
2. **Consistent Colors**: Use same colors for related activities
3. **Realistic Times**: Consider actual school hours
4. **Appropriate Duration**: Match actual activity length

### Organization

1. **Group Similar Events**: Use consistent naming and colors
2. **Review Regularly**: Check your schedule for conflicts
3. **Edit Details**: Add lesson plans and notes after creation
4. **Clean Up**: Remove events that are no longer needed

## Advantages Over Drag-and-Drop

### Reliability

- **No Complex Interactions**: Simple tap-to-select
- **Predictable Results**: Know exactly what will be created
- **No Constraints**: No time or position limitations
- **Consistent Behavior**: Works the same every time

### Efficiency

- **Batch Creation**: Create multiple events at once
- **Quick Selection**: Use Select All/Clear All buttons
- **Visual Feedback**: See results before creating
- **Less Error**: No accidental dragging or resizing

### User Experience

- **Intuitive**: Clear, simple interface
- **Accessible**: Easy to use on all devices
- **Fast**: Quick creation and editing
- **Flexible**: Any combination of days

## Troubleshooting

### Common Issues

1. **No Days Selected**: Make sure to select at least one day
2. **Wrong Time**: Double-check start time and duration
3. **Too Many Events**: Be selective about which days to include
4. **Color Issues**: Choose colors that work well together

### Tips

1. **Start Small**: Create events for a few days first
2. **Test Times**: Make sure times work with your schedule
3. **Use Colors**: Different colors help distinguish events
4. **Edit Later**: Add details after creating basic events

## Future Enhancements

### Potential Improvements

1. **Templates**: Save common event patterns
2. **Copy/Paste**: Duplicate events across different weeks
3. **Bulk Edit**: Edit multiple events at once
4. **Smart Suggestions**: Suggest optimal times based on existing events

### Advanced Features

1. **Recurring Patterns**: Set up weekly/monthly recurring events
2. **Conflict Detection**: Warn about overlapping events
3. **Auto-Scheduling**: Suggest best times for new events
4. **Export/Import**: Share schedules with other teachers

---

This multi-day selection system provides a much more reliable and efficient way to create events across multiple days. It's perfect for teachers who need to set up recurring activities and weekly schedules quickly and accurately!
