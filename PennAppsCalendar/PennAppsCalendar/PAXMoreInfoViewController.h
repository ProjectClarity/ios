//
//  PAXMoreInfoViewController.h
//  PennAppsCalendar
//
//  Created by Jennifer Zhang on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PAXEvent.h"

@interface PAXMoreInfoViewController : UIViewController <MKMapViewDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *eventMapView;
@property (strong, nonatomic) PAXEvent *event;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *getTicketsButton;
@property (weak, nonatomic) IBOutlet UIButton *getUberButton;
@property (weak, nonatomic) IBOutlet UIButton *getRemindersButton;

- (IBAction)handleEventLinkInEventbrite:(id)sender;

- (IBAction)handleEventLinkInUber:(id)sender;

- (IBAction)toggleRemindersForCurrentEvent:(id)sender;

@end
