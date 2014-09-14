//
//  PAXEventDataController.h
//  PennAppsCalendar
//
//  Created by Benjamin Y Chan on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAXEvent.h"
#import <MapKit/MapKit.h>

@interface PAXEventDataController : NSObject

+ (PAXEventDataController *)sharedEventDataController;

#pragma mark - Event Access

/**
 * A simple pin for authentication/knowing which user
 */
@property (assign) NSUInteger authPin;

/**
 * The window into all data that should be displayed
 */
@property (readonly, strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) CLGeocoder *geocoder;

/**
 * precalculate a travel destination
 */
- (void)addTravelDestination:(NSString *)destination;

/**
 * Grab travel information for the given destination
 */
- (NSString *)travelInfoForDestination:(NSString *)destination;

/**
 * An array of pending changes to the fetchedResultsController. Observe
 * this property to update accordingly.
 */
@property (readonly) NSArray *pendingChanges;

/**
 * Ask the data controller to fetch the next set of events.
 * This will update the core data stack when a successful fetch occurs.
 */
- (void)fetchMoreEventsWithCallback:(void(^)(void))callback;

/**
 * Update all events in the core data stack from the server.
 */
- (void)refreshAllEventsWithCallback:(void(^)(void))callback;

- (void)deleteEvent:(PAXEvent *)event;


@end
