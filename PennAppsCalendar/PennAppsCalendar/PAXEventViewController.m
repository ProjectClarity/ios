//
//  PAXEventViewController.m
//  PennAppsCalendar
//
//  Created by Jennifer Zhang on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import "PAXEventViewController.h"
#import "PAXEventDataController.h"
#import "PAXEventCollectionViewCell.h"

@interface PAXEventViewController ()

@property (strong, nonatomic) PAXEventDataController *eventDataController;
@property (strong, nonatomic) NSArray *eventsArray;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;



@end

@implementation PAXEventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Establishing a location manager that will start updating the location of the user
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    
    PAXEvent *event1 = [[PAXEvent alloc] init];
    PAXEvent *event2 = [[PAXEvent alloc] init];
    
    self.eventsArray = @[event1, event2];

    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    
//    self.eventDataController = [PAXEventDataController sharedEventDataController];
//    self.eventsArray = [self.eventDataController eventsAfterDate:[NSDate date] fetchCount:5];
    
}

#pragma mark - Collection View

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PAXEventCollectionViewCell *eventCell = [self.eventsCollectionView dequeueReusableCellWithReuseIdentifier:@"eventCell" forIndexPath:indexPath];
    
    PAXEvent *event = self.eventsArray[indexPath.row];
    
    eventCell.backgroundColor = [UIColor redColor];
    eventCell.eventNameLabel.text = @"Event Name"; //should grab event.name
    eventCell.eventMinutesLabel.text = @"In X Minutes"; //should grab difference between current date and event.date
    eventCell.eventLocationLabel.text = @"Location"; //should grab event.location
    
    return eventCell;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}


- (void)convertAddressToCoordinates:(NSString *)address ofEvent:(PAXEvent *)event
{
    if(!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    [self.geocoder geocodeAddressString:address
                      completionHandler:^(NSArray* placemarks, NSError* error){
                          event.location = [((CLPlacemark *)[placemarks firstObject])location];
                      }];
    
}

- (void)calculatingTimeToLocationOfEvent:(PAXEvent *)event
{
    
    //CLLocationDistance distanceFromEvent = [event.location distanceFromLocation:[self.locationManager location]];
    //CLLocationSpeed speedUserIsMoving = [event.location speed];
    
    //event.minutesToEvent = (distanceFromEvent/speedUserIsMoving) / 60.0;
    
}


-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self performSegueWithIdentifier:@"eventMoreInfo" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
