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

@interface PAXEventViewController () <UIAlertViewDelegate>
@property (strong, nonatomic) PAXEventDataController *eventDataController;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIRefreshControl *refresher;
@property (weak, nonatomic) IBOutlet UIImageView *eventTimeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *eventArrowUpImageView;
@property (weak, nonatomic) IBOutlet UIButton *scrollToTopButton;
@property (weak, nonatomic) IBOutlet UILabel *eventMinutesLabel;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbarView;

@property (strong, nonatomic) UIAlertView *alert;
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
    
    
    // add a green outline to the toolbar
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.toolbarView.frame.size.height - 1, self.toolbarView.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:23.0/255.0 green:163.0/255.0 blue:102.0/255.0 alpha:0.80].CGColor;
    [self.toolbarView.layer addSublayer:bottomBorder];
    
    
    //Establishing a location manager that will start updating the location of the user
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    
    
    //Swipes left and right
    UISwipeGestureRecognizer * swipeleft =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    
    UISwipeGestureRecognizer* swiperight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.eventsCollectionView addGestureRecognizer:swiperight];
    
    
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

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    
    [self showAlertWithTitle:@"Deleting Event" message:@"Are you sure you want to delete?" confirmButton:@"OK" cancelButton:@"Cancel" andTag:0];
    
}

-(void)showAlertWithTitle:(NSString *)title message:(NSString *)message confirmButton:(NSString *)confirmMessage cancelButton:(NSString *)cancelMessage andTag:(NSInteger)tag
{
    
    self.alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:confirmMessage
                                          otherButtonTitles:cancelMessage, nil];
    
    self.alert.tag = tag;
    [self.alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 0) {
        if (buttonIndex == 0) {
            NSIndexPath *indexPath = [self.eventsCollectionView indexPathsForVisibleItems][0];
            [self.eventDataController deleteEvent:[self.eventDataController.fetchedResultsController objectAtIndexPath:indexPath]];
        }
    }
}

- (IBAction)scrollToTop:(id)sender
{
    [self.eventsCollectionView scrollToItemAtIndexPath:0 atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

#pragma mark - Collection View

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PAXEventCollectionViewCell *eventCell = [self.eventsCollectionView dequeueReusableCellWithReuseIdentifier:@"eventCell" forIndexPath:indexPath];
    
    PAXEvent *event = [self.eventDataController.fetchedResultsController objectAtIndexPath:indexPath];
    NSInteger minutesToEvent = (NSInteger)([event.startDate timeIntervalSinceDate:[NSDate date]] / 60);
    if (minutesToEvent < 0) {
        self.eventMinutesLabel.text = @"happening now";
    }
    else if (minutesToEvent < 60) {
        if (minutesToEvent == 1) {
            self.eventMinutesLabel.text = [NSString stringWithFormat:@"in %lu minute", (unsigned long)minutesToEvent];
        } else {
            self.eventMinutesLabel.text = [NSString stringWithFormat:@"in %lu minutes", (unsigned long)minutesToEvent];
        }
    } else if (minutesToEvent >= 60 && minutesToEvent < (26*60)) {
        NSUInteger hoursToEvent = (int)(minutesToEvent / 60);
        if (hoursToEvent == 1) {
            self.eventMinutesLabel.text = [NSString stringWithFormat:@"in %lu hour", (unsigned long) hoursToEvent];
        } else {
           self.eventMinutesLabel.text = [NSString stringWithFormat:@"in %lu hours", (unsigned long) hoursToEvent];
        }
    } else {
        NSUInteger daysToEvent = (int)(minutesToEvent / (60 * 24));
        if (daysToEvent == 1) {
            self.eventMinutesLabel.text = [NSString stringWithFormat:@"in %lu day", (unsigned long) daysToEvent];
        } else {
            self.eventMinutesLabel.text = [NSString stringWithFormat:@"in %lu days", (unsigned long) daysToEvent];
        }
    }
    
    if (event.notes != nil) {
        eventCell.eventNotesLabel.hidden = NO;
        eventCell.eventNotesLabel.textColor = [UIColor colorWithRed:239.0/255.0 green:108.0/255.0 blue:99.0/255.0 alpha:0.75];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *dayString = [dateFormatter stringFromDate:event.startDate];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    NSString *timeString = [dateFormatter stringFromDate:event.startDate];
    NSString *timeEndString = [dateFormatter stringFromDate:event.endDate];
    NSMutableString *combinedDateString = [NSMutableString stringWithCapacity:5];
    [combinedDateString appendString:dayString];
    [combinedDateString appendString:@" "];
    [combinedDateString appendString:timeString];
    if (timeEndString != nil) {
        [combinedDateString appendString:@"-"];
        [combinedDateString appendString:timeEndString];
    }
    
    eventCell.backgroundColor = [UIColor whiteColor];
    eventCell.eventNameLabel.text = event.name; //should grab event.name
    if (!event.location) {
        eventCell.eventLocationLabel.text = @"No location"; //should grab event.location
    }
    else {
        eventCell.eventLocationLabel.text = event.location; //should grab event.location
    }
    eventCell.eventMinutesLabel.text = [combinedDateString copy];
    eventCell.eventDescriptionLabel.text = event.notes;
    if (event.geoLocation) {
        eventCell.eventWalkingTimeLabel.text = [self.eventDataController travelInfoForDestination:event.geoLocation];
    }
    else {
        eventCell.eventWalkingTimeLabel.text = @"unavailable";
    }

    
    self.eventTimeImageView.image = [self.eventTimeImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.eventTimeImageView setTintColor:[UIColor colorWithRed:23.0/255.0 green:163.0/255.0 blue:102.0/255.0 alpha:1.00]];
    
    self.eventArrowUpImageView.image = [self.eventArrowUpImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.eventArrowUpImageView setTintColor:[UIColor colorWithRed:23.0/255.0 green:163.0/255.0 blue:102.0/255.0 alpha:1.00]];
    
    eventCell.eventTimeImageView.image = [self.eventTimeImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [eventCell.eventTimeImageView setTintColor:[UIColor colorWithRed:239.0/255.0 green:108.0/255.0 blue:99.0/255.0 alpha:0.75]];
    
    eventCell.eventLocationImageView.image = [eventCell.eventLocationImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [eventCell.eventLocationImageView setTintColor:[UIColor colorWithRed:239.0/255.0 green:108.0/255.0 blue:99.0/255.0 alpha:0.75]];
    
    eventCell.eventWalkingTimeImageView.image = [eventCell.eventWalkingTimeImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [eventCell.eventWalkingTimeImageView setTintColor:[UIColor colorWithRed:239.0/255.0 green:108.0/255.0 blue:99.0/255.0 alpha:0.75]];

    [self createEventNameUI:eventCell.eventNameLabel];
    [self createEventTimeUI:self.eventMinutesLabel];
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
    eventName.textColor = [UIColor whiteColor];//[UIColor colorWithRed:239.0/255.0 green:84.0/255.0 blue:87.0/255.0 alpha:1.00];
    eventName.font = [UIFont fontWithName:@"Montserrat-Bold" size:26.0];
    eventName.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:84.0/255.0 blue:87.0/255.0 alpha:1.00];
    eventName.layer.cornerRadius = 5;
    eventName.clipsToBounds = YES;
    
}

- (void)createEventTimeUI:(UILabel *)eventLabel
{
    eventLabel.textColor = [UIColor colorWithRed:23.0/255.0 green:163.0/255.0 blue:102.0/255.0 alpha:1.00];
    eventLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:22.0];
}

- (void)createEventOtherInfoUI:(UILabel *)eventLabel
{
    eventLabel.textColor = [UIColor colorWithRed:143.0/255.0 green:145.0/255.0 blue:156.0/255.0 alpha:1.00];
    eventLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:17.0];
    
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
        
        NSIndexPath *indexPath = [self.eventsCollectionView indexPathsForVisibleItems][0];
        
        PAXEvent *event = [self.eventDataController.fetchedResultsController objectAtIndexPath:indexPath];
    
        moreInfoVC.event = event;
    }
}

- (IBAction)unwindToEvents:(UIStoryboardSegue *)unwindSegue
{
    if([unwindSegue.identifier isEqualToString:@"backToEvents"]){
        PAXMoreInfoViewController *controller = unwindSegue.sourceViewController;
    }
}


@end
