# Complete Drag & Drop Guide

This guide explains all the drag and drop functionality in the teacher planner, including moving events between days, changing times, and resizing event duration.

## 🎯 **Overview**

The teacher planner now supports comprehensive drag and drop functionality:

1. **Move Events Between Days**: Drag horizontally to change days
2. **Change Event Times**: Drag vertically to change start time
3. **Resize Event Duration**: Drag bottom edge to extend/shrink events
4. **Visual Feedback**: Clear indicators for all drag operations

## 🚀 **Drag & Drop Features**

### **1. Move Between Days (Horizontal Drag)**

- **How to**: Drag event left or right
- **Visual Feedback**: Green highlight on target day
- **Result**: Event moves to new day
- **Constraint**: Stays within Mon-Fri

### **2. Change Start Time (Vertical Drag)**

- **How to**: Drag event up or down
- **Visual Feedback**: Blue highlight on target time slot
- **Result**: Event start time changes
- **Constraint**: Stays within 6 AM - 6 PM

### **3. Resize Event Duration (Bottom Edge Drag)**

- **How to**: Drag bottom edge of event up or down
- **Visual Feedback**: Resize handle at bottom
- **Result**: Event duration changes (1-8 hours)
- **Constraint**: Minimum 1 hour, maximum 8 hours

## 📱 **How to Use**

### **Moving Events Between Days**

1. **Long press** any event
2. **Drag horizontally** to desired day
3. **Look for green highlight** on target day
4. **Release** to move event
5. **Event updates** to new day

### **Changing Event Times**

1. **Long press** any event
2. **Drag vertically** to desired time slot
3. **Look for blue highlight** on target time
4. **Release** to change time
5. **Event updates** to new start time

### **Resizing Event Duration**

1. **Find resize handle** at bottom of event
2. **Drag handle up** to shorten event
3. **Drag handle down** to extend event
4. **Watch duration update** in real-time
5. **Release** to set new duration

## 🎨 **Visual Indicators**

### **Drag Feedback**

- **Dragging Preview**: Event follows cursor with shadow
- **Placeholder**: Original position shows as grey box
- **Drop Zones**: Highlight when hovering

### **Drop Zone Colors**

- **Blue Highlight**: Time slot drop zone (vertical)
- **Green Highlight**: Day drop zone (horizontal)
- **Transparent**: No drop zone active

### **Resize Handle**

- **Location**: Bottom edge of each event
- **Style**: White bar with rounded corners
- **Size**: 8px height, full width
- **Indicator**: Small white line in center

## 🔧 **Technical Implementation**

### **Drop Zones Structure**

```dart
// Time slot drop zones (vertical)
...List.generate(totalH, (hourIndex) {
  return Positioned(
    left: 0,
    top: hourIndex * slotH,
    child: DragTarget<EventBlock>(
      onAccept: (event) {
        event.startHour = hour;
        event.day = day;
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: candidateData.isNotEmpty
              ? Colors.blue.withOpacity(0.1)
              : Colors.transparent,
        );
      },
    ),
  );
}),

// Day drop zones (horizontal)
...List.generate(days.length, (dayIndex) {
  return Positioned(
    left: dayIndex * colW,
    top: 0,
    child: DragTarget<EventBlock>(
      onAccept: (event) {
        event.day = targetDay;
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: candidateData.isNotEmpty
              ? Colors.green.withOpacity(0.1)
              : Colors.transparent,
        );
      },
    ),
  );
}),
```

### **Resize Handle**

```dart
Positioned(
  bottom: 0,
  left: 0,
  right: 0,
  child: GestureDetector(
    onPanUpdate: (details) {
      final newHeight = height + details.delta.dy;
      final newDuration = (newHeight / slotH).round();
      if (newDuration >= 1 && newDuration <= 8) {
        e.duration = newDuration;
        _computeLayouts();
      }
    },
    child: Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
      ),
    ),
  ),
)
```

## 📋 **Use Cases**

### **Moving Events Between Days**

- **Schedule Changes**: Move class to different day
- **Conflict Resolution**: Move overlapping events
- **Flexible Planning**: Adjust weekly schedule

### **Changing Event Times**

- **Time Adjustments**: Move class to different time
- **Bell Schedule**: Align with school bell times
- **Break Management**: Adjust for recess/lunch

### **Resizing Event Duration**

- **Extended Classes**: Make longer lessons
- **Short Activities**: Reduce duration for quick tasks
- **Flexible Blocks**: Adjust for different activity types

## 🎯 **Best Practices**

### **Drag & Drop**

1. **Use Visual Feedback**: Watch for highlighted drop zones
2. **Plan Your Moves**: Think before dragging
3. **Check Constraints**: Stay within time bounds (6 AM - 6 PM)
4. **Test Positioning**: Verify events land where expected

### **Resizing**

1. **Start Small**: Begin with small adjustments
2. **Watch Duration**: Monitor the time display
3. **Respect Limits**: Stay within 1-8 hour range
4. **Consider Conflicts**: Avoid overlapping events

### **General Tips**

1. **Practice First**: Try with test events
2. **Use Preview**: Long press to preview before editing
3. **Undo Mistakes**: Edit events to fix positioning
4. **Save Regularly**: Changes are auto-saved

## 🔍 **Troubleshooting**

### **Drag Issues**

1. **Event not dragging**: Make sure to long press first
2. **Can't drop**: Check if drop zone is highlighted
3. **Wrong position**: Verify time bounds (6 AM - 6 PM)
4. **Day not changing**: Ensure you're dragging horizontally

### **Resize Issues**

1. **Handle not visible**: Look for white bar at bottom
2. **Not resizing**: Make sure you're dragging the handle
3. **Duration not updating**: Check if within 1-8 hour range
4. **Layout problems**: Events automatically reorganize

### **Visual Issues**

1. **No highlights**: Check if dragging over drop zones
2. **Wrong colors**: Blue = time, Green = day
3. **Handle missing**: Ensure event is large enough to show handle

## 🚀 **Advanced Features**

### **Multi-Event Operations**

- **Batch Moving**: Move multiple events at once
- **Group Resizing**: Resize related events together
- **Pattern Copying**: Copy event patterns across days

### **Smart Constraints**

- **Conflict Detection**: Warn about overlapping events
- **Time Validation**: Prevent invalid time ranges
- **Day Limits**: Respect school day boundaries

### **Visual Enhancements**

- **Snap to Grid**: Snap to 15-minute intervals
- **Ghost Preview**: Show where event will land
- **Undo/Redo**: Track drag operations

## 📊 **Performance Tips**

### **Smooth Dragging**

1. **Limit Event Count**: Too many events may slow down
2. **Optimize Layout**: Events automatically reorganize
3. **Use Efficient Gestures**: Long press then drag
4. **Close Other Apps**: Free up device resources

### **Memory Management**

1. **Regular Cleanup**: Remove unused events
2. **Efficient Updates**: Layout recomputes automatically
3. **State Management**: Changes are immediately saved

---

This comprehensive drag and drop system provides maximum flexibility for managing your teacher planner schedule!
