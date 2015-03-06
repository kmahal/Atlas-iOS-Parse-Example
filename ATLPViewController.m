//
//  ParseLoginViewController.m
//  LayerParseTest
//
//  Created by Abir Majumdar on 3/4/15.
//  Copyright (c) 2015 Abir Majumdar. All rights reserved.
//

#import "ATLPViewController.h"

@interface ATLPViewController ()

@end

@implementation ATLPViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![PFUser currentUser]) { // No user logged in

        // Create the log in view controller
        self.logInViewController = [[PFLogInViewController alloc] init];
        self.logInViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.self.logInViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.logInViewController.fields = (PFLogInFieldsUsernameAndPassword |
                                PFLogInFieldsLogInButton |
                                PFLogInFieldsSignUpButton |
                                PFLogInFieldsPasswordForgotten);
        [self.logInViewController setDelegate:self]; // Set ourselves as the delegate
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"parse_logo.png"]];
        logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.logInViewController.logInView.logo = logoImageView;
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        UIImageView *signupImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"parse_logo2.png"]];
        signupImageView.contentMode = UIViewContentModeScaleAspectFit;
        signUpViewController.signUpView.logo = signupImageView;
        
        // Assign our sign up controller to be displayed from the login controller
        [self.logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:self.logInViewController animated:YES completion:NULL];
    }
    else{
        [self loginLayer];
    }
}

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self loginLayer];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
    //[self presentViewController:logInController animated:YES completion:NULL];
}


#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}


#pragma mark - IBActions

- (IBAction)logOutButtonTapAction:(id)sender {
    [PFUser logOut];
    [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Failed to deauthenticate: %@", error);
        } else {
            NSLog(@"Previous user deauthenticated");
        }
    }];
    
    // Present the log in view controller
    [self presentViewController:self.logInViewController animated:YES completion:NULL];
}

#pragma mark - Layer Authentication Methods

- (void)loginLayer
{
    // Connect to Layer
    // See "Quick Start - Connect" for more details
    // https://developer.layer.com/docs/quick-start/ios#connect
    [self.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Failed to connect to Layer: %@", error);
        } else {
            PFUser *user = [PFUser currentUser];
            NSString *userID = user.objectId;
            [self authenticateLayerWithUserID:userID completion:^(BOOL success, NSError *error) {
                if (!success) {
                    NSLog(@"Failed Authenticating Layer Client with error:%@", error);
                }
            }];
        }
    }];
    
    
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce,
                                                                 NSError *error) {
        //NSLog(@"Authentication nonce %@", nonce);
        
        // Upon reciept of nonce, post to your backend and acquire a Layer
        // identityToken
        if (nonce) {
            PFUser *user = [PFUser currentUser];
            NSString *userID = user.objectId;
            [PFCloud
             callFunctionInBackground:@"generateToken"
             withParameters:@{
                              @"nonce" : nonce,
                              @"userID" : userID
                              } block:^(NSString *token, NSError *error) {
                                  if (!error) {
                                      // Send the Identity Token to Layer to authenticate the
                                      // user
                                      [self.layerClient
                                       authenticateWithIdentityToken:
                                       token completion:^(NSString *authenticatedUserID,
                                                          NSError *error) {
                                           if (!error) {
                                               NSLog(@"Parse User authenticated with Layer "
                                                     @"Identity Token");
                                           } else {
                                               NSLog(@"Parse User failed to authenticate with "
                                                     @"token with error: %@",
                                                     error);
                                           }
                                       }];
                                  } else {
                                      NSLog(@"Parse Cloud function failed to be called to "
                                            @"generate token with error: %@",
                                            error);
                                  }
                              }];
        }
    }];
}

- (void)authenticateLayerWithUserID:(NSString *)userID completion:(void (^)(BOOL success, NSError * error))completion
{
    if (self.layerClient.authenticatedUserID) {
        NSLog(@"Layer Authenticated as User %@", self.layerClient.authenticatedUserID);
        
        [self presentConversationListViewController];
        
        if (completion) completion(YES, nil);
        return;
    }
    
    // Authenticate with Layer
    // See "Quick Start - Authenticate" for more details
    // https://developer.layer.com/docs/quick-start/ios#authenticate
    
    /*
     * 1. Request an authentication Nonce from Layer
     */
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        NSLog(@"Authentication nonce %@", nonce);
        
        // Upon reciept of nonce, post to your backend and acquire a Layer
        // identityToken
        if (nonce) {
            [PFCloud
             callFunctionInBackground:@"generateToken"
             withParameters:@{
                              @"nonce" : nonce,
                              @"userID" : userID
                              } block:^(NSString *token, NSError *error) {
                                  if (!error) {
                                      // Send the Identity Token to Layer to authenticate the
                                      // user
                                      [self.layerClient
                                       authenticateWithIdentityToken:
                                       token completion:^(NSString *authenticatedUserID,
                                                          NSError *error) {
                                           if (!error) {
                                               NSLog(@"Parse User authenticated with Layer "
                                                     @"Identity Token");
                                               [self presentConversationListViewController];
                                           } else {
                                               NSLog(@"Parse User failed to authenticate with "
                                                     @"token with error: %@",
                                                     error);
                                           }
                                       }];
                                  } else {
                                      NSLog(@"Parse Cloud function failed to be called to "
                                            @"generate token with error: %@",
                                            error);
                                  }
                              }];
        }
    }];
}

- (void)presentConversationListViewController
{
    ConversationListViewController *controller = [ConversationListViewController  conversationListViewControllerWithLayerClient:self.layerClient];
    //[self.rootViewController pushViewController:controller animated:YES];
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
