//
//  PAXEventViewController.h
//  PennAppsCalendar
//
//  Created by Jennifer Zhang on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PAXEventViewController : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventMinutesLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *eventScrollView;



@end
