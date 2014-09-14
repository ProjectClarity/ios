//
//  PAXEvent.h
//  PennAppsCalendar
//
//  Created by Jennifer Zhang on 9/14/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PAXEvent : NSManagedObject

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * eventbriteURL;
@property (nonatomic, retain) NSString * geoLocation;
@property (nonatomic, retain) NSNumber * googleSort;
@property (nonatomic, retain) NSString * lastCalculatedDistance;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * ownerName;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * ownerEmail;

@end
