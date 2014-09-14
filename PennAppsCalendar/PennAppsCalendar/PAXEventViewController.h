//
//  PAXEventViewController.h
//  PennAppsCalendar
//
//  Created by Jennifer Zhang on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PAXBackgroundLayer.h"

@interface PAXEventViewController : UIViewController <CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>


@property (weak, nonatomic) IBOutlet UICollectionView *eventsCollectionView;


@end
