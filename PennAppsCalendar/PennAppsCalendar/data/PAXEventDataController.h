//
//  PAXEventDataController.h
//  PennAppsCalendar
//
//  Created by Benjamin Y Chan on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAXEvent.h"

@interface PAXEventDataController : NSObject

+ (id)sharedEventDataController;

#pragma mark - Event Access

/**
 * Get an array of events after the given date,
 * limited to at most fetchCount.
 */
- (void)processEventsAfterDate:(NSDate *)date fetchCount:(NSUInteger)count withHandler:(void(^)(PAXEvent *event))eventHandler;

@end
