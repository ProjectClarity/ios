//
//  PAXMoreInfoViewController.m
//  PennAppsCalendar
//
//  Created by Jennifer Zhang on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import "PAXMoreInfoViewController.h"

@interface PAXMoreInfoViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) CLLocation *eventGeoLocation;

@end

@implementation PAXMoreInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self convertAddressToCoordinates:self.event.location ofEvent:self.event withCallback:^{
        // asynchronously called
        [self locateEventOnMap];
        [self zoomToLocation];
        NSLog(@"%@", self.event.location);
        NSLog(@"%@", self.eventGeoLocation);
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.eventNameLabel.text = self.event.name;
    
    [self createEventNameUI:self.eventNameLabel];
    [self.eventMapView setShowsUserLocation:YES];
    
    UISwipeGestureRecognizer* swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];
    
}

- (void)createEventNameUI:(UILabel *)eventName
{
    eventName.textColor = [UIColor whiteColor];
    eventName.font = [UIFont fontWithName:@"Montserrat-Bold" size:26.0];
    eventName.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:84.0/255.0 blue:87.0/255.0 alpha:1.00];
    eventName.layer.cornerRadius = 5;
    eventName.clipsToBounds = YES;
    
}

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self performSegueWithIdentifier:@"backToEvents" sender:self];
}

- (void)convertAddressToCoordinates:(NSString *)address
                            ofEvent:(PAXEvent *)event
                       withCallback:(void(^)(void))callback
{
    if(!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    [self.geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            self.eventGeoLocation = placemark.location;
        }
        callback();
    }];
    
}

# pragma mark - Event Map

- (void)locateEventOnMap
{
    self.eventMapView.centerCoordinate = self.eventGeoLocation.coordinate;
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = self.eventMapView.centerCoordinate;
    point.title = self.event.name;
    
    [self.eventMapView addAnnotation:point];
}

-(void)zoomToLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (self.eventGeoLocation.coordinate, 3000, 3000);
    [self.eventMapView setRegion:region animated:NO];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
