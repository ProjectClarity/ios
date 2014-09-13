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

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * uid;

@end