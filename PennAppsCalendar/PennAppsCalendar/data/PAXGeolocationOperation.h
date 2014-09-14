//
//  PAXGeolocationOperation.h
//  PennAppsCalendar
//
//  Created by Benjamin Y Chan on 9/14/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAXEvent.h"

@interface PAXGeolocationOperation : NSOperation
- (id)initWithEvent:(PAXEvent *)event;
@end
