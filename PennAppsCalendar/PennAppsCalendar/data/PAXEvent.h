//
//  PAXEvent.h
//  PennAppsCalendar
//
//  Created by Benjamin Y Chan on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PAXEvent : NSManagedObject

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSData * geoLocation;
@property (nonatomic, retain) NSString * location;

@end
