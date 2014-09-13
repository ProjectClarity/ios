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
#import "PAXEvent.h"
#import "PAXMoreInfoViewController.h"

@interface PAXEventViewController ()
@property (strong, nonatomic) PAXEventDataController *eventDataController;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) UIRefreshControl *refresher;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CAGradientLayer *backgroundLayer = [PAXBackgroundLayer skyGradient];
    backgroundLayer.frame = self.view.frame;
    [self.eventsCollectionView.backgroundView.layer insertSublayer:backgroundLayer atIndex:0];
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.eventDataController = [PAXEventDataController sharedEventDataController];
    [self.eventDataController addObserver:self forKeyPath:@"pendingChanges" options:0 context:0];
    
    
    if (!self.refresher) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor grayColor];
        self.refresher = refreshControl;
        [self.eventsCollectionView addSubview:self.refresher];
        [self.refresher addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    }
    self.eventsCollectionView.alwaysBounceVertical = YES;
    
    
    [self.eventDataController refreshAllEventsWithCallback:^{
        NSLog(@"first load!");
    }]; // TODO
    
    //Establishing a location manager that will start updating the location of the user
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.eventDataController) {
        NSLog(@"UPDATING... SHOULD ONLY BE CALLED ONCE");
        [self updateCollectionViewWithChanges:self.eventDataController.pendingChanges];
    }
}

#pragma mark - Gestures

- (void)refresh
{
    [self.eventDataController refreshAllEventsWithCallback:^{
        [self.refresher endRefreshing];
    }];
}

-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self performSegueWithIdentifier:@"eventMoreInfo" sender:self];
}

#pragma mark - Collection View

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PAXEventCollectionViewCell *eventCell = [self.eventsCollectionView dequeueReusableCellWithReuseIdentifier:@"eventCell" forIndexPath:indexPath];
    
    PAXEvent *event = [self.eventDataController.fetchedResultsController objectAtIndexPath:indexPath];
    NSInteger minutesToEvent = (NSInteger)([event.startDate timeIntervalSinceDate:[NSDate date]] / 60);
    if (minutesToEvent < 0) {
        eventCell.eventMinutesLabel.text = @"Happening Now";
    }
    else if (minutesToEvent < 60) {
        if (minutesToEvent == 1) {
            eventCell.eventMinutesLabel.text = [NSString stringWithFormat:@"In %lu Minute", (unsigned long)minutesToEvent];
        } else {
            eventCell.eventMinutesLabel.text = [NSString stringWithFormat:@"In %lu Minutes", (unsigned long)minutesToEvent];
        }
    } else if (minutesToEvent >= 60 && minutesToEvent < (26*60)) {
        NSUInteger hoursToEvent = (int)(minutesToEvent / 60);
        if (hoursToEvent == 1) {
            eventCell.eventMinutesLabel.text = [NSString stringWithFormat:@"In %lu Hour", (unsigned long) hoursToEvent];
        } else {
            eventCell.eventMinutesLabel.text = [NSString stringWithFormat:@"In %lu Hours", (unsigned long) hoursToEvent];
        }
    } else {
        NSUInteger daysToEvent = (int)(minutesToEvent / (60 * 24));
        if (daysToEvent == 1) {
            eventCell.eventMinutesLabel.text = [NSString stringWithFormat:@"In %lu Day", (unsigned long) daysToEvent];
        } else {
            eventCell.eventMinutesLabel.text = [NSString stringWithFormat:@"In %lu Days", (unsigned long) daysToEvent];
        }
    }
    
    eventCell.backgroundColor = [UIColor whiteColor];
    eventCell.eventNameLabel.text = event.name; //should grab event.name
    eventCell.eventLocationLabel.text = event.location; //should grab event.location

    
    eventCell.eventTimeImageView.image = [eventCell.eventTimeImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [eventCell.eventTimeImageView setTintColor:[UIColor colorWithRed:239.0/255.0 green:108.0/255.0 blue:99.0/255.0 alpha:0.75]];
    
    eventCell.eventLocationImageView.image = [eventCell.eventLocationImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [eventCell.eventLocationImageView setTintColor:[UIColor colorWithRed:239.0/255.0 green:108.0/255.0 blue:99.0/255.0 alpha:0.75]];
    
    eventCell.eventWalkingTimeImageView.image = [eventCell.eventWalkingTimeImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [eventCell.eventWalkingTimeImageView setTintColor:[UIColor colorWithRed:239.0/255.0 green:108.0/255.0 blue:99.0/255.0 alpha:0.75]];

    [self createEventNameUI:eventCell.eventNameLabel];
    [self createEventOtherInfoUI:eventCell.eventMinutesLabel];
    [self createEventOtherInfoUI:eventCell.eventLocationLabel];
    [self createEventOtherInfoUI:eventCell.eventWalkingTimeLabel];

    return eventCell;
    
}

- (void)updateCollectionViewWithChanges:(NSArray *)changes
{
    [self.eventsCollectionView reloadData];
    /*[self.eventsCollectionView performBatchUpdates:^{
        
        for (NSDictionary *change in changes)
        {
            [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch (type)
                {
                    case NSFetchedResultsChangeInsert:
                        [self.eventsCollectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.eventsCollectionView deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        [self.eventsCollectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeMove:
                        [self.eventsCollectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                }
            }];
        }
    } completion:nil];*/
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.eventDataController.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

#pragma mark - UI

- (void)createEventNameUI:(UILabel *)eventName
{
    eventName.textColor = [UIColor whiteColor];
    eventName.font = [UIFont fontWithName:@"Montserrat-Bold" size:26.0];
    eventName.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:84.0/255.0 blue:87.0/255.0 alpha:1.00];
    eventName.layer.cornerRadius = 5;
    eventName.clipsToBounds = YES;
    
}

- (void)createEventOtherInfoUI:(UILabel *)eventLabel
{
    eventLabel.textColor = [UIColor colorWithRed:143.0/255.0 green:145.0/255.0 blue:156.0/255.0 alpha:1.00];
    eventLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:20.0];
    
}

- (void)createEventLocationUI:(UILabel *)eventName
{
    eventName.textColor = [UIColor whiteColor];
    eventName.font = [UIFont fontWithName:@"Montserrat-Regular" size:20.0];
    eventName.backgroundColor = [UIColor colorWithRed:208.0/255.0 green:142.0/255.0 blue:137.0/255.0 alpha:1.00];
    eventName.layer.cornerRadius = 5;
    eventName.clipsToBounds = YES;
    
}

- (void)createEventWalkingTimeUI:(UILabel *)eventName
{
    eventName.textColor = [UIColor whiteColor];
    eventName.font = [UIFont fontWithName:@"Montserrat-Regular" size:20.0];
    eventName.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:145.0/255.0 blue:156.0/255.0 alpha:1.00];
    eventName.layer.cornerRadius = 5;
    eventName.clipsToBounds = YES;
    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"eventMoreInfo"]) {
        
        PAXMoreInfoViewController *moreInfoVC = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.eventsCollectionView indexPathForCell:sender];
        
        PAXEvent *event = [self.eventDataController.fetchedResultsController objectAtIndexPath:indexPath];
    
        moreInfoVC.event = event;
    }
}


@end
