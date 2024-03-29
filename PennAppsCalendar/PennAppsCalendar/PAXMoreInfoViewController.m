//
//  PAXMoreInfoViewController.m
//  PennAppsCalendar
//
//  Created by Jennifer Zhang on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import "PAXMoreInfoViewController.h"
#import "PAXWebviewViewController.h"
#import "PAXEventDataController.h"
#import "PAXEventNotificationCenter.h"

@interface PAXMoreInfoViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) CLLocation *eventGeoLocation;
@property (weak, nonatomic) IBOutlet UIImageView *ticketsImageView;
@property (weak, nonatomic) IBOutlet UIImageView *uberImageView;
@property (weak, nonatomic) IBOutlet UIImageView *remindersImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventHostNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *contactHostButton;

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
    self.eventHostNameLabel.text = [NSString stringWithFormat:@"Event Host: %@", self.event.ownerName];
    self.eventHostNameLabel.textColor = [UIColor colorWithRed:143.0/255.0 green:145.0/255.0 blue:156.0/255.0 alpha:1.00];
    
    [self createEventNameUI:self.eventNameLabel];
    [self.eventMapView setShowsUserLocation:YES];
    
    UISwipeGestureRecognizer* swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];
    
    if (!self.event.eventbriteURL) {
        [self.getTicketsButton setEnabled:NO];
    }
    
    [self createRoundButtonUI:self.getTicketsButton];
    [self createRoundButtonUI:self.getUberButton];
    [self createRoundButtonUI:self.getRemindersButton];
    [self createContactButtonUI:self.contactHostButton];
    
    self.ticketsImageView.image = [self.ticketsImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if (!self.getTicketsButton.enabled) {
        [self.ticketsImageView setTintColor:[UIColor colorWithRed:200.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:0.75]];
    }
    else {
        [self.ticketsImageView setTintColor:[UIColor colorWithRed:239.0/255.0 green:84.0/255.0 blue:87.0/255.0 alpha:0.75]];
    }
    
    self.uberImageView.image = [self.uberImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.uberImageView setTintColor:[UIColor colorWithRed:239.0/255.0 green:84.0/255.0 blue:87.0/255.0 alpha:0.75]];
    
    self.remindersImageView.image = [self.remindersImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self updateRemindersImageViewColor];

    
}

- (void)updateRemindersImageViewColor
{
    BOOL isReminderScheduled = [PAXEventNotificationCenter isNotificationScheduledForEvent:self.event];
    NSLog(@"Is reminder scheduled: %d", isReminderScheduled);
    if (!isReminderScheduled) {
        [self.remindersImageView setTintColor:[UIColor colorWithRed:239.0/255.0 green:84.0/255.0 blue:87.0/255.0 alpha:0.75]];
    }
    else {
        [self.remindersImageView setTintColor:[UIColor colorWithRed:85.0/255.0 green:240.0/255.0 blue:87.0/255.0 alpha:0.75]];
        
    }
}

#pragma mark - UI

- (void)createRoundButtonUI: (UIButton *)button
{
    button.layer.cornerRadius = button.frame.size.width/2;
    button.clipsToBounds = YES;
    
    button.layer.borderWidth = 3.0f;
    if (!button.enabled) {
        button.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:0.75].CGColor;
    }
    else {
        button.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:84.0/255.0 blue:87.0/255.0 alpha:0.75].CGColor;
    }
}

- (void)createContactButtonUI:(UIButton *)button
{
    [[button titleLabel] setFont:[UIFont fontWithName:@"Montserrat-Regular" size:17.0]];
    [button setTintColor:[UIColor colorWithRed:23.0/255.0 green:163.0/255.0 blue:102.0/255.0 alpha:1.00]];
    [button setBackgroundColor:[UIColor whiteColor]];
    [[button layer] setBorderWidth:3.0f];
    [[button layer] setBorderColor:[UIColor colorWithRed:23.0/255.0 green:163.0/255.0 blue:102.0/255.0 alpha:1.00].CGColor];
    button.layer.cornerRadius = 5;
    button.clipsToBounds = YES;
    
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

// Leave this for now, because while we are latituding/longituding everything,
// we can only persist that as a string without more engineering work.
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
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (self.eventGeoLocation.coordinate, 1000, 1000);
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

- (UIImage *)getRoundedRectImageFromImage :(UIImage *)image onReferenceView :(UIImageView*)imageView withCornerRadius :(float)cornerRadius
{
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                                cornerRadius:cornerRadius] addClip];
    [image drawInRect:imageView.bounds];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

#pragma mark - Third Party integration

- (void)handleEventLinkInEventbrite:(id)sender
{
    if (!self.event.eventbriteURL) {
        return;
    }
    NSURL *myURL = [NSURL URLWithString:self.event.eventbriteURL];
   /* NSURL *interAppURL = [NSURL URLWithString:@"com-eventbrite-attendee://"];
    if ([[UIApplication sharedApplication] canOpenURL:interAppURL]) {
        // Handle with the eventbrite app
        [[UIApplication sharedApplication] openURL:myURL];
        return;
    }*/
    // Open the eventbrite website in own webview
    PAXWebviewViewController *webViewController = [[PAXWebviewViewController alloc] initWithNibName:@"PAXWebviewViewController" bundle:[NSBundle mainBundle]];
    webViewController.url = myURL;
    [self presentViewController:webViewController animated:YES completion:^{
        [webViewController loadPage];
        NSLog(@"completed");
    }];
}

- (void)handleEventLinkInUber:(id)sender
{
    NSLog(@"HANDLING UBER EVENT");
    
    CLLocation *currentLocation = [PAXEventDataController sharedEventDataController].currentLocation;

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]) {
        // Do something awesome - the app is installed! Launch App.
        NSMutableString *queryString = [NSMutableString stringWithString:@"uber://?action=setPickup"];
        if (currentLocation) {
            [queryString appendString:[NSString stringWithFormat:@"&pickup[latitude]=%f&pickup[longitude]=%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude]];
        }
        if (self.event.geoLocation) {
            NSArray *coords = [self.event.geoLocation componentsSeparatedByString:@","];
            if (coords.count == 2) {
                CGFloat latitude = [coords[0] floatValue];
                CGFloat longitude = [coords[1] floatValue];
                [queryString appendString:[NSString stringWithFormat:@"&dropoff[latitude]=%f&dropoff[longitude]=%f", latitude, longitude]];
            }
        }
        if (self.event.location) {
            [queryString appendString:[NSString stringWithFormat:@"&dropoff[nickname]=%@", self.event.location]];

        }
        NSString *finalURL = [queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        NSURL *integrationURL = [NSURL URLWithString:finalURL];
        [[UIApplication sharedApplication] openURL:integrationURL];
    }
    else {
        // No Uber app! Open Mobile Website.
        NSURL *integrationURL = [NSURL URLWithString:@"https://m.uber.com/sign-up?client_id=PAXPennAppsLOL"];
        [[UIApplication sharedApplication] openURL:integrationURL];
    }
}

- (IBAction)toggleRemindersForCurrentEvent:(id)sender
{
    if ([PAXEventNotificationCenter isNotificationScheduledForEvent:self.event]) {
        [PAXEventNotificationCenter unscheduleReminderForEvent:self.event];
    }
    else {
        [PAXEventNotificationCenter scheduleReminderForEvent:self.event];
    }
    [self updateRemindersImageViewColor];
}

@end
