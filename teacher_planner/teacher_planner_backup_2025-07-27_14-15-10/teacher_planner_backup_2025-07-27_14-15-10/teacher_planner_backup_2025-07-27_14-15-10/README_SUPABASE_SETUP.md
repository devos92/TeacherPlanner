# Supabase Curriculum Database Setup

This guide will help you set up the Supabase database for the Teacher Planner app's curriculum integration.

## 🚀 Quick Setup

### 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up or log in
3. Click "New Project"
4. Choose your organization
5. Enter project details:
   - **Name**: `teacher-planner-curriculum`
   - **Database Password**: Choose a strong password
   - **Region**: Choose closest to you
6. Click "Create new project"

### 2. Get Your Project Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy your **Project URL** and **anon public key**
3. Update `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
}
```

### 3. Set Up the Database Schema

1. In your Supabase dashboard, go to **SQL Editor**
2. Copy and paste the contents of `supabase_schema.sql`
3. Click "Run" to create the tables

### 4. Initialize the Curriculum Data

1. Run the app
2. The app will automatically initialize the curriculum database
3. Check the console logs for initialization status

## 📊 Database Schema

The curriculum database consists of 4 main tables:

### `curriculum_years`

- Stores year levels (Foundation, Year 1-10)
- Fields: `id`, `name`, `description`

### `curriculum_subjects`

- Stores learning areas (English, Mathematics, Science, etc.)
- Fields: `id`, `name`, `code`, `description`

### `curriculum_strands`

- Stores subject strands (Language, Literature, Number & Algebra, etc.)
- Fields: `id`, `subject_id`, `name`, `description`

### `curriculum_outcomes`

- Stores curriculum outcomes/content descriptions
- Fields: `id`, `strand_id`, `code`, `description`, `elaboration`, `year_level`

## 🔧 Features

### ✅ **What's Included:**

- **Complete Australian Curriculum v9.0** data
- **All learning areas**: English, Mathematics, Science, HASS, Arts, Technologies, Health & PE, Languages
- **All year levels**: Foundation to Year 10
- **Full-text search** capabilities
- **Caching** for performance
- **Fallback to local data** if Supabase is unavailable

### 🚀 **Performance Benefits:**

- **Instant data access** - No network delays
- **Reliable connectivity** - No API rate limits
- **Offline capability** - Local fallback
- **Real-time updates** - Supabase real-time subscriptions
- **Scalable** - Handles growth easily

### 🔍 **Search Capabilities:**

- Search by outcome code (e.g., "ACELA1428")
- Search by description keywords
- Search by elaboration text
- Full-text search across all fields

## 🛠 Development

### Testing the Connection

Use the API test page to verify connectivity:

```dart
// Test Supabase connection
final results = await SupabaseCurriculumService.testConnection();
print('Connection test results: $results');
```

### Adding More Curriculum Data

To add more curriculum data:

1. **Manual**: Use the Supabase dashboard to add records
2. **Bulk Import**: Use the SQL import feature
3. **API**: Use the Supabase API to programmatically add data

### Monitoring

Check the Supabase dashboard for:

- **Database usage** and performance
- **API requests** and rate limits
- **Real-time subscriptions** activity
- **Error logs** and debugging

## 🔒 Security

The database is configured with:

- **Row Level Security (RLS)** enabled
- **Public read access** for curriculum data
- **No write access** for anonymous users
- **Proper indexing** for performance

## 📱 App Integration

The app automatically:

1. **Initializes** Supabase on startup
2. **Loads curriculum data** when needed
3. **Caches responses** for performance
4. **Falls back** to local data if needed
5. **Searches outcomes** efficiently

## 🐛 Troubleshooting

### Common Issues:

1. **Connection failed**

   - Check your Supabase URL and key
   - Verify internet connectivity
   - Check Supabase project status

2. **No data loaded**

   - Run the schema SQL first
   - Check initialization logs
   - Verify table permissions

3. **Slow performance**
   - Check database indexes
   - Monitor query performance
   - Consider caching strategies

### Debug Commands:

```dart
// Test connection
final test = await SupabaseCurriculumService.testConnection();

// Check cache stats
final stats = SupabaseCurriculumService.getCacheStats();

// Clear cache
SupabaseCurriculumService.clearCache();
```

## 📈 Next Steps

1. **Deploy to production** with your Supabase project
2. **Add user authentication** for personalized features
3. **Implement real-time updates** for collaborative features
4. **Add analytics** to track usage patterns
5. **Scale the database** as needed

## 🎯 Benefits of This Approach

✅ **Reliable** - No more API connectivity issues  
✅ **Fast** - Instant data access  
✅ **Scalable** - Handles growth easily  
✅ **Offline-capable** - Local fallback  
✅ **Searchable** - Full-text search  
✅ **Real-time** - Live updates  
✅ **Secure** - Proper authentication  
✅ **Cost-effective** - Supabase free tier

This Supabase integration provides a robust, scalable solution for curriculum data that will serve the Teacher Planner app well into the future!
