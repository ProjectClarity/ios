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
 * The window into all data that should be displayed
 */
@property (readonly, strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

/**
 * Ask the data controller to fetch the next set of events.
 * This will update the core data stack when a successful fetch occurs.
 */
- (void)fetchMoreEvents;

/**
 * Update all events in the core data stack from the server.
 */
- (void)refreshAllEvents;


@end
