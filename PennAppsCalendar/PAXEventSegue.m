//
//  PAXEventSegue.m
//  PennAppsCalendar
//
//  Created by Jennifer Zhang on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import "PAXEventSegue.h"

@implementation PAXEventSegue

- (void) perform {
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;
//    [UIView transitionWithView:src.navigationController.view duration:0.7
//                       options:UIViewAnimationOptionCurveEaseOut
//                    animations:^{
//                        [src.navigationController pushViewController:dst animated:NO];
//                    }
//                    completion:NULL];
    
    [UIView animateWithDuration:0.6f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [src.navigationController pushViewController:dst animated:YES];
                     }
                     completion:NULL];

}

@end
