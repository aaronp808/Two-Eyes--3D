#ifndef Logger_h
#define Logger_h

/*
 * There are three levels of logging: debug, info and error, and each can be enabled independently
 * via the LOGGING_LEVEL_DEBUG, LOGGING_LEVEL_INFO, and LOGGING_LEVEL_ERROR switches below, respectively.
 * In addition, ALL logging can be enabled or disabled via the LOGGING_ENABLED switch below.
 *
 * To perform logging, use any of the following function calls in your code:
 *
 * LogDebug(fmt, ...) – will print if LOGGING_LEVEL_DEBUG is set on.
 * LogInfo(fmt, ...) – will print if LOGGING_LEVEL_INFO is set on.
 * LogWarn(fmt, ...) - will print if LOGGING_LEVEL_WARN is set on.
 * LogError(fmt, ...) – will print if LOGGING_LEVEL_ERROR is set on.
 *
 * Each logging entry can optionally include the thread name by enabling the
 * LOGGING_INCLUDE_THREAD_NAME switch. Use "[[NSThread currentThread] setName:@"MainThread"];" to set in code.
 *
 * Each logging entry can optionally include a timestamp by enabling the
 * LOGGING_INCLUDE_TIMESTAMP switch. The timestamp format is configurable by changing
 * LOGGING_TIMESTAMP_FORMAT. Take a look at: http://unicode.org/reports/tr35/tr35-10.html#Date_Format_Patterns
 *
 * Each logging entry can optionally include class, method and line information by
 * enabling the LOGGING_INCLUDE_CODE_LOCATION switch.
 *
 * Logging functions are implemented here via macros, so disabling logging, either entirely,
 * or at a specific level, removes the corresponding log invocations from the compiled code,
 * thus completely eliminating both the memory and CPU overhead that the logging calls would add.
 */

// Set this switch to enable or disable ALL logging.
#define LOGGING_ENABLED DEBUG

// Set any or all of these switches to enable or disable logging at specific levels.
#define LOGGING_LEVEL_DEBUG 1
#define LOGGING_LEVEL_INFO 1
#define LOGGING_LEVEL_WARN 1
#define LOGGING_LEVEL_ERROR 1

// Set this switch to set whether or not to include the thread name.
#define LOGGING_INCLUDE_THREAD_NAME 0

// Set this switch to set whether or not to include a timestamp using the format defined just below.
#define LOGGING_TIMESTAMP_FORMAT @"MM-dd-yy HH:mm:ss.SS"
#define LOGGING_INCLUDE_TIMESTAMP 0

// Set this switch to set whether or not to include class, method and line information in the log entries.
#define LOGGING_INCLUDE_CODE_LOCATION 1

// ***************** END OF USER SETTINGS ***************

#if !(defined(LOGGING_ENABLED) && LOGGING_ENABLED)
#undef LOGGING_LEVEL_DEBUG
#undef LOGGING_LEVEL_INFO
#undef LOGGING_LEVEL_WARN
#undef LOGGING_LEVEL_ERROR
#endif

// Logging format
/*#define LOG_FORMAT_NO_LOCATION(fmt, lvl, ...) NSLog((@"[%@] " fmt), lvl, ##__VA_ARGS__)
#define LOG_FORMAT_WITH_LOCATION(fmt, lvl, ...) NSLog((@"%s [Line %d] [%@] " fmt), __PRETTY_FUNCTION__, __LINE__, lvl, ##__VA_ARGS__)

#if defined(LOGGING_INCLUDE_CODE_LOCATION) && LOGGING_INCLUDE_CODE_LOCATION
#define LOG_FORMAT(fmt, lvl, ...) LOG_FORMAT_WITH_LOCATION(fmt, lvl, ##__VA_ARGS__)
#else
#define LOG_FORMAT(fmt, lvl, ...) LOG_FORMAT_NO_LOCATION(fmt, lvl, ##__VA_ARGS__)
#endif*/

//#define LOG_FORMAT(lvl, args...) _Logger(__FILE__, __PRETTY_FUNCTION__, __LINE__, lvl, LOGGING_INCLUDE_THREAD_NAME, LOGGING_INCLUDE_CODE_LOCATION, LOGGING_INCLUDE_TIMESTAMP, LOGGING_TIMESTAMP_FORMAT, args)

// Debug level logging
#if defined(LOGGING_LEVEL_DEBUG) && LOGGING_LEVEL_DEBUG
//#define LogDebug(args...) LOG_FORMAT(@"DEBUG", args...)
#define LogD() LogDebug(@"")
#define LogDebug(args...) _Logger(__FILE__, __PRETTY_FUNCTION__, __LINE__, @"DEBUG", LOGGING_INCLUDE_THREAD_NAME, LOGGING_INCLUDE_CODE_LOCATION, LOGGING_INCLUDE_TIMESTAMP, LOGGING_TIMESTAMP_FORMAT, args)
#else
#define LogD(...)
#define LogDebug(...)
#endif

// Info level logging
#if defined(LOGGING_LEVEL_INFO) && LOGGING_LEVEL_INFO
//#define LogInfo(args...) LOG_FORMAT(@"INFO", args...)
#define LogI() LogInfo(@"")
#define LogInfo(args...) _Logger(__FILE__, __PRETTY_FUNCTION__, __LINE__, @"INFO", LOGGING_INCLUDE_THREAD_NAME, LOGGING_INCLUDE_CODE_LOCATION, LOGGING_INCLUDE_TIMESTAMP, LOGGING_TIMESTAMP_FORMAT, args)
#else
#define LogI(...)
#define LogInfo(...)
#endif

// Warn level logging
#if defined(LOGGING_LEVEL_INFO) && LOGGING_LEVEL_WARN
//#define LogWarn(args...) LOG_FORMAT(@"WARN", args...)
#define LogW() LogWarn(@"")
#define LogWarn(args...) _Logger(__FILE__, __PRETTY_FUNCTION__, __LINE__, @"WARN", LOGGING_INCLUDE_THREAD_NAME, LOGGING_INCLUDE_CODE_LOCATION, LOGGING_INCLUDE_TIMESTAMP, LOGGING_TIMESTAMP_FORMAT, args)
#else
#define LogW(...)
#define LogWarn(...)
#endif

// Error level logging
#if defined(LOGGING_LEVEL_ERROR) && LOGGING_LEVEL_ERROR
//#define LogError(args...) LOG_FORMAT(@"ERROR", args...)
#define LogE() LogError(@"")
#define LogError(args...) _Logger(__FILE__, __PRETTY_FUNCTION__, __LINE__, @"ERROR", LOGGING_INCLUDE_THREAD_NAME, LOGGING_INCLUDE_CODE_LOCATION, LOGGING_INCLUDE_TIMESTAMP, LOGGING_TIMESTAMP_FORMAT, args)
#else
#define LogE(...)
#define LogError(...)
#endif

void _Logger(const char *file, const char *funcName, int lineNumber, NSString *level,
             int includeThread, int includeLoc, int includeTime, NSString *timeFormat,
             NSString *format, ...);

#endif
