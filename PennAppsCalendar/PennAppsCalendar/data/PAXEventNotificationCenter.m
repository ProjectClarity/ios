//
//  PAXEventNotificationCenter.m
//  PennAppsCalendar
//
//  Created by Benjamin Y Chan on 9/14/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import "PAXEventNotificationCenter.h"

@implementation PAXEventNotificationCenter

+ (NSMutableDictionary *)scheduledNotifications {
    static NSMutableDictionary *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[NSMutableDictionary alloc] initWithCapacity:5];
    });
    return singleton;
}

+ (void)scheduleReminderForEvent:(PAXEvent *)event
{
    if (!event.startDate) {
        return;
    }
    UILocalNotification *reminder = [[UILocalNotification alloc] init];
    reminder.fireDate = [event.startDate dateByAddingTimeInterval:-(11*60)];
    reminder.timeZone = [NSTimeZone defaultTimeZone];
    reminder.alertBody = [NSString stringWithFormat:@"%@ is happening in %i minutes.", event.name, 11];
    reminder.alertAction = @"Details";
    [[UIApplication sharedApplication] scheduleLocalNotification:reminder];
    [self scheduledNotifications][event.uid] = reminder;
}

+ (void)unscheduleReminderForEvent:(PAXEvent *)event
{
    [[UIApplication sharedApplication] cancelLocalNotification:[self notificationScheduledForEventID:event.uid]];
    [[self scheduledNotifications] removeObjectForKey:event.uid];
}

+ (BOOL)isNotificationScheduledForEvent:(PAXEvent *)event
{
    return ([self notificationScheduledForEventID:event.uid] != nil);
}

+ (void)unscheduleAllReminders
{
    [[self scheduledNotifications] removeAllObjects];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

+ (UILocalNotification *)notificationScheduledForEventID:(NSString *)eid
{
    return [self scheduledNotifications][eid];
}

@end
