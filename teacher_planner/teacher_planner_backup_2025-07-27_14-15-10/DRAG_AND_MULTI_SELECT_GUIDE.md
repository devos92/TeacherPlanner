# Drag & Multi-Select Event Guide

This guide explains both the drag-and-drop functionality and the new multi-select mode for creating events with different times.

## Overview

The app now features two powerful event creation modes:

1. **Same Time (Multi-Day)**: Create events with identical times across multiple days
2. **Different Times (Multi-Select)**: Create events with different times for each day
3. **Drag & Drop**: Move events between days and time slots

## Event Creation Modes

### Mode 1: Same Time (Multi-Day)

Perfect for recurring activities with consistent scheduling:

- **Lunch**: 12:00-13:00 across all days
- **Recess**: 10:30-11:00 across all days
- **Assembly**: 8:00-9:00 on specific days

**How to use:**

1. Tap "+" button
2. Choose "Same Time (Multi-Day)"
3. Enter title, subtitle, color
4. Select days using filter chips
5. Set one time/duration for all selected days
6. Create multiple events at once

### Mode 2: Different Times (Multi-Select)

Perfect for classes with varying schedules:

- **English**: Mon 9:00-10:00, Wed 14:00-15:00, Fri 11:00-12:00
- **Math**: Tue 8:00-9:00, Thu 13:00-14:00
- **Science**: Mon 15:00-16:00, Wed 10:00-11:00

**How to use:**

1. Tap "+" button
2. Choose "Different Times"
3. Enter title, subtitle, color
4. Add event slots for each occurrence
5. Set different day/time/duration for each slot
6. Create events with varying schedules

## Drag & Drop Functionality

### How It Works

- **Drag Events**: Long-press and drag any event
- **Drop Zones**: Each time slot is a drop zone
- **Visual Feedback**: See where you can drop
- **Automatic Updates**: Events update position and time

### Drag Features

- **Move Between Days**: Drag horizontally to change days
- **Change Times**: Drag vertically to change start time
- **Visual Feedback**:
  - Dragging shows event preview
  - Drop zones highlight in blue
  - Original position shows as placeholder

### Drag Constraints

- **Time Bounds**: Events stay within 6 AM - 6 PM
- **Duration Preserved**: Event duration doesn't change when dragging
- **Day Limits**: Can only drop on valid days (Mon-Fri)

## Step-by-Step Guides

### Creating Events with Same Time

1. **Open Creation Dialog**

   - Tap "+" button
   - Choose "Same Time (Multi-Day)"

2. **Enter Event Info**

   - Title: "Math Class"
   - Subtitle: "Grade 5"
   - Color: Blue

3. **Select Days**

   - Tap chips for Mon, Wed, Fri
   - See count: "Will create 3 events"

4. **Set Schedule**

   - Start Time: 9:00 AM
   - Duration: 1 hour
   - End Time: 10:00 AM (calculated)

5. **Create Events**
   - Tap "Create Events"
   - 3 events appear in week view

### Creating Events with Different Times

1. **Open Creation Dialog**

   - Tap "+" button
   - Choose "Different Times"

2. **Enter Event Info**

   - Title: "English Class"
   - Subtitle: "Grade 6"
   - Color: Green

3. **Add Event Slots**

   - Slot 1: Mon 9:00-10:00
   - Slot 2: Wed 14:00-15:00
   - Slot 3: Fri 11:00-12:00

4. **Review Summary**

   - See all scheduled times
   - Verify correct days and times

5. **Create Events**
   - Tap "Create 3 Events"
   - Events appear with different times

### Dragging Events

1. **Start Dragging**

   - Long-press any event
   - Drag to desired position

2. **Visual Feedback**

   - Event preview follows cursor
   - Drop zones highlight in blue
   - Original position shows placeholder

3. **Drop Event**
   - Release over desired time slot
   - Event updates to new day/time
   - Layout automatically adjusts

## Code Implementation

### Drag & Drop Logic

```dart
Draggable<EventBlock>(
  data: event,
  feedback: Material(
    elevation: 8,
    child: Container(
      // Dragging preview
    ),
  ),
  childWhenDragging: Container(
    // Placeholder when dragging
  ),
  child: GestureDetector(
    // Event display
  ),
)
```

### Drop Zone Implementation

```dart
DragTarget<EventBlock>(
  onWillAccept: (data) => true,
  onAccept: (event) {
    setState(() {
      event.startHour = hour;
      event.day = day;
      _computeLayouts();
    });
  },
  builder: (context, candidateData, rejectedData) {
    return Container(
      color: candidateData.isNotEmpty
          ? Colors.blue.withOpacity(0.1)
          : Colors.transparent,
    );
  },
)
```

### Multi-Select Event Slots

```dart
class EventSlot {
  final String day;
  final int startHour;
  final int duration;

  EventSlot({
    required this.day,
    required this.startHour,
    required this.duration,
  });
}
```

## Use Cases

### Same Time Mode

- **Daily Activities**: Lunch, recess, assembly
- **Regular Classes**: Same time every occurrence
- **Routine Events**: Consistent scheduling

### Different Times Mode

- **Flexible Classes**: Varying schedules
- **Special Events**: Different times each day
- **Complex Schedules**: Mixed timing requirements

### Drag & Drop

- **Quick Adjustments**: Move events easily
- **Schedule Changes**: Update times on the fly
- **Conflict Resolution**: Move overlapping events

## Best Practices

### Event Creation

1. **Choose Right Mode**: Same time vs different times
2. **Plan Ahead**: Think about your schedule needs
3. **Use Descriptive Titles**: Make events easy to identify
4. **Color Coding**: Use consistent colors for related activities

### Drag & Drop

1. **Check Time Bounds**: Stay within 6 AM - 6 PM
2. **Avoid Conflicts**: Don't overlap events
3. **Use Visual Feedback**: Watch for highlighted drop zones
4. **Test Positioning**: Verify events land where expected

### Multi-Select

1. **Add Slots Carefully**: Only add what you need
2. **Review Summary**: Check all times before creating
3. **Remove Unused Slots**: Keep it clean
4. **Plan Schedule**: Think about optimal times

## Troubleshooting

### Drag & Drop Issues

1. **Events not dragging**: Make sure to long-press
2. **Can't drop**: Check if drop zone is highlighted
3. **Wrong position**: Verify time bounds (6 AM - 6 PM)
4. **Layout issues**: Events automatically reorganize

### Multi-Select Issues

1. **No slots**: Add at least one event slot
2. **Wrong times**: Double-check each slot's time
3. **Too many events**: Remove unnecessary slots
4. **Validation errors**: Fill in all required fields

### General Issues

1. **Events not appearing**: Check if creation was successful
2. **Wrong colors**: Verify color selection
3. **Missing details**: Edit events to add notes
4. **Performance**: Too many events may slow down the app

## Advanced Features

### Drag Enhancements

- **Snap to Grid**: Snap to 15-minute intervals
- **Multi-Select Drag**: Drag multiple events at once
- **Undo/Redo**: Track drag operations
- **Conflict Detection**: Warn about overlaps

### Multi-Select Enhancements

- **Templates**: Save common slot patterns
- **Copy/Paste**: Duplicate slot configurations
- **Bulk Edit**: Edit multiple slots at once
- **Smart Suggestions**: Suggest optimal times

### Future Improvements

1. **Time Constraints**: Set custom time bounds
2. **Recurring Patterns**: Weekly/monthly recurring events
3. **Export/Import**: Share schedules
4. **Collaboration**: Multi-user editing

## Comparison of Modes

| Feature         | Same Time            | Different Times   | Drag & Drop       |
| --------------- | -------------------- | ----------------- | ----------------- |
| **Use Case**    | Recurring activities | Varying schedules | Quick adjustments |
| **Setup Time**  | Fast                 | Medium            | Instant           |
| **Flexibility** | Limited              | High              | Very High         |
| **Complexity**  | Simple               | Medium            | Simple            |
| **Best For**    | Daily routines       | Complex schedules | Quick changes     |

---

This comprehensive system provides maximum flexibility for creating and managing your teacher planner. Choose the right mode for your needs and use drag-and-drop for quick adjustments!
