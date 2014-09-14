//
//  PAXWebviewViewController.m
//  PennAppsCalendar
//
//  Created by Benjamin Y Chan on 9/14/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import "PAXWebviewViewController.h"

@interface PAXWebviewViewController () <UIWebViewDelegate>

@end

@implementation PAXWebviewViewController

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
    self.webView.delegate = self;
    [self.progressView setProgress:0.0];
    // Do any additional setup after loading the view from its nib.
    [[UILabel appearance] setFont:[UIFont fontWithName:@"Montserrat-Regular" size:15.0]];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"Webveiw load started");
    [self.progressView setProgress:0.6 animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Webview did finish load");
    [self.progressView setProgress:1.0 animated:YES];
    [self.progressView setHidden:YES];
}

- (void)setUrl:(NSURL *)url
{
    if (url != _url) {
        _url = url;
    }
}

- (void)loadPage
{
    NSURLRequest *requestObject = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:requestObject];
    [self.progressView setHidden:NO];
    [self.progressView setProgress:0.4 animated:YES];
    NSLog(@"Loading request object: %@", requestObject);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Eventbrite view controller dismissed");
    }];
}

@end
