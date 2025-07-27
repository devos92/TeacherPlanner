# Complete Supabase Setup Guide for Teacher Planner

## 🚀 Overview

This guide will help you set up the complete Supabase integration for the Teacher Planner app, including:

- ✅ **Database Schema** - All tables for events, reflections, attachments
- ✅ **Image Storage** - Automatic cloud storage for all images
- ✅ **Authentication** - User accounts and security
- ✅ **Real-time Updates** - Live sync across devices
- ✅ **Search & Analytics** - Full-text search and statistics

## 📋 Prerequisites

1. **Supabase Account**: Sign up at [supabase.com](https://supabase.com)
2. **Project Created**: You should already have your project running
3. **Credentials Ready**: Your project URL and anon key should be in `lib/config/supabase_config.dart`

## 🗄️ Step 1: Expand the Database Schema

### Run the Original Schema (if not done)

1. Go to your Supabase dashboard
2. Navigate to **SQL Editor**
3. Copy and paste the contents of `supabase_schema.sql`
4. Click **Run**

### Add the New Tables and Features

1. In the same **SQL Editor**
2. Copy and paste the contents of `supabase_schema_expansion.sql`
3. Click **Run**

This will create:

- `teacher_profiles` - User profiles and preferences
- `enhanced_events` - Lesson plans and events
- `daily_reflections` - Daily teaching reflections
- `attachments` - File metadata (images, documents)
- `hyperlinks` - Website links for lessons
- `event_outcomes` - Curriculum outcome mappings
- `lesson_templates` - Reusable lesson templates
- `shared_resources` - Community sharing features

## 🪣 Step 2: Set Up Storage Buckets

### Enable Storage

1. Go to **Storage** in your Supabase dashboard
2. The app will automatically create these buckets when first run:
   - `lesson-images` (10MB limit, images only)
   - `lesson-documents` (50MB limit, PDFs, docs)
   - `teacher-avatars` (2MB limit, profile pictures)

### Manual Setup (if needed)

If automatic creation fails, create buckets manually:

1. Click **New Bucket**
2. Create each bucket with these settings:

**lesson-images:**

- Name: `lesson-images`
- Public: ✅ Yes
- File size limit: `10485760` (10MB)
- Allowed MIME types: `image/jpeg,image/png,image/gif,image/webp`

**lesson-documents:**

- Name: `lesson-documents`
- Public: ✅ Yes
- File size limit: `52428800` (50MB)
- Allowed MIME types: `application/pdf,application/msword,text/plain`

**teacher-avatars:**

- Name: `teacher-avatars`
- Public: ✅ Yes
- File size limit: `2097152` (2MB)
- Allowed MIME types: `image/jpeg,image/png`

## 🔐 Step 3: Configure Authentication

### Enable Email Authentication

1. Go to **Authentication** → **Settings**
2. Under **User Signups**, toggle **Enable email confirmations** (optional)
3. Configure your **Site URL** (for production deployment)

### Set Up Email Templates (Optional)

1. Go to **Authentication** → **Email Templates**
2. Customize signup and recovery emails

## 🧪 Step 4: Test the Integration

### Run the App

```bash
flutter clean
flutter pub get
flutter run
```

### Check Console Output

Look for these success messages:

```
✅ Supabase initialized successfully
📁 Storage buckets created/verified
🔐 Authentication ready
```

### Test Features

1. **Authentication**: Try signup/login
2. **Image Upload**: Add an image to a lesson
3. **Database**: Create events and reflections
4. **Storage**: Verify files appear in Supabase storage

## 🚨 Troubleshooting

### Common Issues

**"MissingPluginException for path_provider"**

- Fixed by our enhanced error handling
- App will fallback to alternative directories

**"Failed to create storage bucket"**

- Check your project permissions
- Ensure you're on a paid Supabase plan if needed
- Create buckets manually (see Step 2)

**"RLS policy violation"**

- User must be authenticated to access data
- Check that `auth.uid()` is properly set

**"Image upload fails"**

- Check file size limits (10MB for images)
- Verify MIME types are allowed
- App will fallback to local storage

### Debug Mode

Enable detailed logging by checking Flutter debug console for:

- `✅` Success messages
- `⚠️` Warning messages
- `❌` Error messages

## 🔄 Step 5: Data Migration

### For Existing Users

If you have existing local data, the app provides migration tools:

```dart
// Migrate local images to Supabase
final migrationResult = await ImageService.migrateLocalImagesToSupabase();
print('Migrated ${migrationResult.length} images to Supabase');
```

### Backup Strategy

1. **Automatic**: All data is backed up to Supabase in real-time
2. **Export**: Use Supabase dashboard to export data
3. **Local**: App maintains local fallbacks for offline use

## 📊 Step 6: Analytics & Search

### Full-Text Search

The setup enables searching across:

- Event titles and descriptions
- Reflection content
- Curriculum outcomes

### Built-in Analytics

Track:

- Events per subject
- Reflection frequency
- Image storage usage
- Curriculum coverage

## 🔄 Step 7: Real-time Features

### Live Updates

When multiple devices are logged in:

- Events sync in real-time
- Reflections appear instantly
- Images upload automatically

### Offline Support

- App continues to work offline
- Data syncs when connection returns
- Local storage as fallback

## 🏃‍♂️ Quick Start Checklist

- [ ] Run `supabase_schema.sql` in SQL Editor
- [ ] Run `supabase_schema_expansion.sql` in SQL Editor
- [ ] Verify storage buckets exist
- [ ] Test app startup (check console for ✅)
- [ ] Create a test user account
- [ ] Upload a test image
- [ ] Create a test event with reflection

## 🆘 Support

### Logs to Check

1. **Flutter Console**: Check for ✅/❌ messages
2. **Supabase Dashboard**: Check API logs
3. **Storage**: Verify files are uploading

### Common Solutions

1. **Reset Flutter**: `flutter clean && flutter pub get`
2. **Check Credentials**: Verify URL and key in config
3. **Manual Bucket Creation**: If auto-creation fails
4. **Clear Browser Cache**: For web testing

## 🎉 You're All Set!

Your Teacher Planner now has:

- 🗄️ **Full Database** with all teacher planning features
- 📁 **Cloud Storage** for unlimited images and files
- 🔐 **User Authentication** with secure access
- 🔍 **Search & Analytics** for powerful insights
- 📱 **Real-time Sync** across all devices
- 🔄 **Offline Support** with automatic sync

The app will automatically handle fallbacks and migrations, ensuring a smooth experience even if some features aren't available.

Happy teaching! 🍎
