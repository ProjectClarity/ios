//
//  PAXHomeViewController.m
//  PennAppsCalendar
//
//  Created by Jennifer Zhang on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import "PAXHomeViewController.h"
#import "PAXEventDataController.h"

@interface PAXHomeViewController ()
@property (nonatomic, weak) IBOutlet UITextField *pinCodeField;
@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;
@property (weak, nonatomic) IBOutlet UILabel *tagline1Label;
@property (weak, nonatomic) IBOutlet UILabel *tagline2Label;
@end

@implementation PAXHomeViewController

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
    // Do any additional setup after loading the view.
    
    [self createButtonUI:self.getStartedButton];
    self.tagline1Label.textColor  = [UIColor colorWithRed:143.0/255.0 green:145.0/255.0 blue:156.0/255.0 alpha:1.00];
    self.tagline2Label.textColor  = [UIColor colorWithRed:163.0/255.0 green:165.0/255.0 blue:176.0/255.0 alpha:1.00];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Weeeeeee
- (IBAction)attemptToPinCodeAndAuth:(id)sender
{
    NSString *pinCodeText = [self.pinCodeField text];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:pinCodeText];
    NSUInteger pin = [myNumber unsignedIntegerValue];
    [[PAXEventDataController sharedEventDataController] setAuthPin:pin];
    [self performSegueWithIdentifier:@"AuthSegue" sender:sender];
}


- (void)createButtonUI:(UIButton *)button
{
    [[button titleLabel] setFont:[UIFont fontWithName:@"Montserrat-Regular" size:17.0]];
    [button setTintColor:[UIColor colorWithRed:23.0/255.0 green:163.0/255.0 blue:102.0/255.0 alpha:1.00]];
    [button setBackgroundColor:[UIColor whiteColor]];
    [[button layer] setBorderWidth:3.0f];
    [[button layer] setBorderColor:[UIColor colorWithRed:23.0/255.0 green:163.0/255.0 blue:102.0/255.0 alpha:1.00].CGColor];
    button.layer.cornerRadius = 5;
    button.clipsToBounds = YES;
    
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
