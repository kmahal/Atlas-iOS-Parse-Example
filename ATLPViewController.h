//
//  ParseLoginViewController.h
//  LayerParseTest
//
//  Created by Abir Majumdar on 3/4/15.
//  Copyright (c) 2015 Abir Majumdar. All rights reserved.
//

#import <LayerKit/LayerKit.h>
#import <Parse/Parse.h>
#import <ParseUI.h>
#import <UIKit/UIKit.h>
#import "ConversationListViewController.h"

@interface ATLPViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) PFLogInViewController *logInViewController;

@end
