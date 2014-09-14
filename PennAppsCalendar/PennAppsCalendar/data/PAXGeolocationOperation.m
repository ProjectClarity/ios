//
//  PAXGeolocationOperation.m
//  PennAppsCalendar
//
//  Created by Benjamin Y Chan on 9/14/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import "PAXGeolocationOperation.h"
#import "PAXEvent.h"
#import "PAXEventDataController.h"
#import <MapKit/MapKit.h>

@interface PAXGeolocationOperation ()
@property (nonatomic, strong) PAXEvent *geoEvent;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, assign) BOOL isExecuting;
@end

@implementation PAXGeolocationOperation

- (id)initWithEvent:(PAXEvent *)event
{
    self = [super init];
    if (self)
    {
        // no setters in init typically but oh well
        self.geoEvent = event;
    }
    return self;
}

- (void)start
{
    // after we have fetched all of the geolocation, update things...
    CLGeocoder *geocoder = [PAXEventDataController sharedEventDataController].geocoder;
    [self willChangeValueForKey:@"isExecuting"];
    self.isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    NSLog(@"starting geolocation");

    [geocoder geocodeAddressString:self.geoEvent.location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"calbacking");
        if ([placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            self.geoEvent.geoLocation = [self stringFromLocation:placemark.location];
            [[PAXEventDataController sharedEventDataController] addTravelDestination:self.geoEvent.geoLocation];
        }
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        self.isExecuting = NO;
        self.isFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
        [self didChangeValueForKey:@"isExecuting"];
    }];
}

// generate a string of form @"%f,%f" from a given CLLocation
- (NSString *)stringFromLocation:(CLLocation *)location
{
    CLLocationCoordinate2D coordinates = [location coordinate];
    NSString *geoLocationString = [NSString stringWithFormat:@"%f,%f", coordinates.latitude, coordinates.longitude];
    return geoLocationString;
}


- (BOOL)isConcurrent
{
    return YES;
}



@end
