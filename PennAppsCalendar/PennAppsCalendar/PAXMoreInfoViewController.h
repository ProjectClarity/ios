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

@end
