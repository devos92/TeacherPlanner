# Custom Time Scheduling Guide

This guide explains the new custom time functionality that allows flexible scheduling for any school timetable.

## Overview

The teacher planner now supports **custom time scheduling** instead of being limited to hourly increments. This allows for:

- **Flexible Start Times**: Any minute between 00-59
- **School-Specific Schedules**: Match your school's exact timetable
- **Precise Scheduling**: No more rounding to the nearest hour
- **Real-World Accuracy**: Reflect actual class times

## How Custom Times Work

### Time Input Fields

- **Hour Field**: Enter 0-23 (24-hour format)
- **Minute Field**: Enter 0-59 (any minute)
- **Validation**: Automatic validation ensures valid times
- **Real-time Updates**: See calculated end times instantly

### Time Display Format

- **24-hour Format**: 14:30 instead of 2:30 PM
- **Leading Zeros**: 09:05 instead of 9:5
- **Consistent Format**: All times displayed uniformly

## Supported Time Formats

### Common School Times

- **8:15 AM** → Enter Hour: 8, Minute: 15
- **2:30 PM** → Enter Hour: 14, Minute: 30
- **11:45 AM** → Enter Hour: 11, Minute: 45
- **3:20 PM** → Enter Hour: 15, Minute: 20

### Special Cases

- **Midnight** → Enter Hour: 0, Minute: 0
- **Noon** → Enter Hour: 12, Minute: 0
- **Early Morning** → Enter Hour: 6, Minute: 30
- **Late Evening** → Enter Hour: 22, Minute: 15

## Using Custom Times

### Creating Events with Custom Times

#### Method 1: Same Time (Multi-Day)

1. **Tap "+"** → Choose "Same Time (Multi-Day)"
2. **Enter Event Info**: Title, subtitle, color
3. **Select Days**: Choose which days
4. **Set Custom Time**:
   - **Hour**: Enter start hour (0-23)
   - **Minute**: Enter start minute (0-59)
   - **Duration**: Choose duration in hours
5. **Review**: See calculated end time
6. **Create**: Events created with custom times

#### Method 2: Different Times (Multi-Select)

1. **Tap "+"** → Choose "Different Times"
2. **Enter Event Info**: Title, subtitle, color
3. **Add Event Slots**: For each occurrence
4. **Set Custom Times**:
   - **Slot 1**: Mon 8:15-9:15
   - **Slot 2**: Wed 14:30-15:30
   - **Slot 3**: Fri 11:45-12:45
5. **Review Summary**: See all scheduled times
6. **Create Events**: Multiple events with different times

### Editing Events with Custom Times

1. **Tap Event**: Opens EventDetailEditor
2. **Modify Time**:
   - Change hour (0-23)
   - Change minute (0-59)
   - Adjust duration
3. **See End Time**: Automatically calculated
4. **Save Changes**: Updates event time

## Time Validation

### Hour Validation

- **Range**: 0-23 (24-hour format)
- **Error**: "Enter 0-23" if invalid
- **Required**: Must be filled

### Minute Validation

- **Range**: 0-59 (any minute)
- **Error**: "Enter 0-59" if invalid
- **Required**: Must be filled

### End Time Calculation

- **Formula**: Start Hour + Duration
- **Example**: 14:30 + 2 hours = 16:30
- **Display**: Shows in same format

## Real-World Examples

### Elementary School Schedule

```
8:15 - 9:00  Morning Assembly
9:00 - 9:45  Math
9:45 - 10:30 English
10:30 - 10:45 Recess
10:45 - 11:30 Science
11:30 - 12:15 Social Studies
12:15 - 1:00 Lunch
1:00 - 1:45  Art
1:45 - 2:30  Physical Education
```

### High School Schedule

```
7:30 - 8:15  Period 1
8:20 - 9:05  Period 2
9:10 - 9:55  Period 3
10:00 - 10:45 Period 4
10:45 - 11:00 Break
11:00 - 11:45 Period 5
11:50 - 12:35 Period 6
12:35 - 1:20 Lunch
1:20 - 2:05  Period 7
2:10 - 2:55 Period 8
```

### Special Education Schedule

```
8:30 - 9:15  Morning Routine
9:15 - 10:00 Individual Work
10:00 - 10:15 Break
10:15 - 11:00 Group Activity
11:00 - 11:45 Lunch Prep
11:45 - 12:30 Lunch
12:30 - 1:15 Afternoon Activity
1:15 - 2:00 Quiet Time
```

## Best Practices

### Time Entry

1. **Use 24-hour Format**: Avoid AM/PM confusion
2. **Be Precise**: Enter exact start times
3. **Check End Times**: Verify calculated end times
4. **Plan Breaks**: Account for transition times

### Schedule Planning

1. **Start Early**: Begin with earliest class
2. **Group Similar Times**: Batch similar activities
3. **Account for Transitions**: Leave buffer time
4. **Test Your Schedule**: Verify all times work

### Validation Tips

1. **Check Hour Range**: 0-23 only
2. **Check Minute Range**: 0-59 only
3. **Verify End Times**: Ensure logical progression
4. **Test Edge Cases**: Midnight, noon, etc.

## Troubleshooting

### Common Issues

#### Invalid Hour Error

- **Problem**: "Enter 0-23" error
- **Solution**: Use 24-hour format (0-23)
- **Example**: 2 PM = 14, not 2

#### Invalid Minute Error

- **Problem**: "Enter 0-59" error
- **Solution**: Minutes must be 0-59
- **Example**: 1:60 is invalid, use 2:00

#### Time Not Saving

- **Problem**: Changes not persisting
- **Solution**: Ensure both fields are valid
- **Check**: Both hour and minute must be valid

#### Display Issues

- **Problem**: Times not showing correctly
- **Solution**: Check leading zeros
- **Format**: Should show as 09:05, not 9:5

### Edge Cases

#### Midnight Times

- **Input**: Hour: 0, Minute: 0
- **Display**: 00:00
- **Note**: Valid for early morning activities

#### Late Evening Times

- **Input**: Hour: 23, Minute: 59
- **Display**: 23:59
- **Note**: Valid for evening activities

#### Single Digit Times

- **Input**: Hour: 9, Minute: 5
- **Display**: 09:05
- **Note**: Leading zeros added automatically

## Code Implementation

### Time Input Fields

```dart
TextFormField(
  initialValue: _startHour.toString(),
  decoration: InputDecoration(
    labelText: 'Start Hour (0-23)',
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.number,
  validator: (v) {
    if (v == null || v.isEmpty) return 'Required';
    final hour = int.tryParse(v);
    if (hour == null || hour < 0 || hour > 23) {
      return 'Enter 0-23';
    }
    return null;
  },
  onSaved: (v) => _startHour = int.parse(v!),
)
```

### Time Display

```dart
Text(
  '${_startHour.toString().padLeft(2, '0')}:${_startMinute.toString().padLeft(2, '0')}',
  style: TextStyle(fontWeight: FontWeight.bold),
)
```

### EventBlock Model

```dart
class EventBlock {
  int startHour;
  int startMinute; // New field for minutes

  EventBlock({
    required this.startHour,
    this.startMinute = 0, // Default to 0 minutes
  });
}
```

## Advanced Features

### Future Enhancements

1. **AM/PM Toggle**: Optional 12-hour format
2. **Time Templates**: Save common time patterns
3. **Duration in Minutes**: Sub-hour durations
4. **Time Zones**: Support for different time zones
5. **Recurring Patterns**: Weekly/monthly recurring times

### Integration Possibilities

1. **Calendar Sync**: Export to external calendars
2. **Bell Schedule**: Integrate with school bell system
3. **Attendance Tracking**: Link to attendance records
4. **Notification System**: Reminders for class times

## Comparison with Hourly System

| Feature              | Hourly System    | Custom Time System |
| -------------------- | ---------------- | ------------------ |
| **Flexibility**      | Limited to hours | Any minute         |
| **Accuracy**         | Rounded to hour  | Precise times      |
| **School Fit**       | Generic          | School-specific    |
| **Setup Time**       | Fast             | Slightly longer    |
| **Real-world Match** | Approximate      | Exact              |

---

This custom time system provides the flexibility needed for any school schedule, from traditional hourly blocks to complex special education timetables!
