//
//  PAXEvent.h
//  PennAppsCalendar
//
//  Created by Benjamin Y Chan on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>


@interface PAXEvent : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * uid;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic) double minutesToEvent;

@end
