//
//  PAXEventInfoDataController.h
//  PennAppsCalendar
//
//  Created by Benjamin Y Chan on 9/14/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAXEventInfoDataController : NSObject

// Singleton client error
+ (id)sharedInfoDataController;


#pragma mark - Distance info

/**
 * Fetch the distances to a list of destinations
 * from a given location (in format @"x.x.x,x.x.x")
 * Process distances using the given callback, with
 * a dictionary with destinations as keys and distances as values
 */
- (void)fetchDistancesToDestinations:(NSArray *)destinations
                        fromLocation:(NSString *)locationString
                        onCompletion:(void(^)(NSDictionary *))completionHandler;

@end
