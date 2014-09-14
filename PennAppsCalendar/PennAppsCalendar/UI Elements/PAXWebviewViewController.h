//
//  PAXWebviewViewController.h
//  PennAppsCalendar
//
//  Created by Benjamin Y Chan on 9/14/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAXWebviewViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;

- (IBAction)done:(id)sender;
- (void)loadPage;

@end
