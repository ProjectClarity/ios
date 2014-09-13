//
//  PAXEventViewController.m
//  PennAppsCalendar
//
//  Created by Jennifer Zhang on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import "PAXEventViewController.h"

@interface PAXEventViewController ()

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

    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    
    
    
    int numberOfPages = 5;
    self.eventScrollView.pagingEnabled = YES;
    self.eventScrollView.contentSize = CGSizeMake(self.eventScrollView.frame.size.width, numberOfPages * self.eventScrollView.frame.size.height);
    
//    for (int i = 0; i < numberOfPages; i++) {
//        UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * self.eventScroll.frame.size.width + 20,
//                                                                      20,
//                                                                      someScrollView.frame.size.width - 40,
//                                                                      20)];
//        tmpLabel.textAlignment = UITextAlignmentCenter;
//        tmpLabel.text = [NSString stringWithFormat:@"This is page %d", i];
//        [someScrollView addSubview:tmpLabel];
//        [tmpLabel release];
//    }
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
