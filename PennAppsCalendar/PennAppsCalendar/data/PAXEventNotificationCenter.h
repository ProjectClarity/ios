//
//  PAXEventNotificationCenter.h
//  PennAppsCalendar
//
//  Created by Benjamin Y Chan on 9/14/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAXEvent.h"

@interface PAXEventNotificationCenter : NSObject

/**
 * Schedule a reminder for the given PAXEvent
 */
+ (void)scheduleReminderForEvent:(PAXEvent *)event;

/**
 * Unschedule all reminders
 */
+ (void)unscheduleAllReminders;

// and more...
+ (void)unscheduleReminderForEvent:(PAXEvent *)event;

+ (BOOL)isNotificationScheduledForEvent:(PAXEvent *)event;


@end
