//
//  ParticipantTableViewController.m
//  LayerParseTest
//
//  Created by Abir Majumdar on 2/28/15.
//
//

#import "ParticipantTableViewController.h"

@interface ParticipantTableViewController ()

@end

@implementation ParticipantTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelTap)];
    self.navigationItem.leftBarButtonItem = cancelItem;
}

- (void)handleCancelTap
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
