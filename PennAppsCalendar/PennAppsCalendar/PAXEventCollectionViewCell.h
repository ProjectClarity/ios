//
//  PAXEventCollectionViewCell.h
//  PennAppsCalendar
//
//  Created by Jennifer Zhang on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAXEventCollectionViewCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventWalkingTimeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *eventLocationImageView;
@property (weak, nonatomic) IBOutlet UIImageView *eventWalkingTimeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *eventTimeImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventMinutesLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDescriptionLabel;

@end
