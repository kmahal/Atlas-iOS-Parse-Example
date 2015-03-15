//
//  ConversationListViewController.m
//  LayerParseTest
//
//  Created by Abir Majumdar on 2/28/15.
//
//
//

#import "ConversationListViewController.h"
#import "ConversationViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface ConversationListViewController () <ATLConversationListViewControllerDelegate, ATLConversationListViewControllerDataSource>

@property (nonatomic) NSArray *usersArray;
@end

@implementation ConversationListViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    self.allowsEditing = false;
    
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonTapped:)];

    UIBarButtonItem *composeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonTapped:)];
    [self.navigationItem setRightBarButtonItem:composeItem];
    [self.navigationItem setLeftBarButtonItem:logoutItem];
    
    [self queryParse];
}

-(void)queryParse
{
    [SVProgressHUD show];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" notEqualTo:self.layerClient.authenticatedUserID]; // find all the women
    [query findObjectsInBackgroundWithBlock:^(NSArray *allUsersArray, NSError *error) {
        [SVProgressHUD dismiss];
        if(!error){
            _usersArray = allUsersArray.copy;
        }
    }];
}

#pragma mark - Conversation List View Controller Delegate Methods

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation
{
    ConversationViewController *controller = [ConversationViewController conversationViewControllerWithLayerClient:self.layerClient];
    controller.participants = _usersArray;
    controller.conversation = conversation;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didDeleteConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode
{
    NSLog(@"Conversation deleted");
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didFailDeletingConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode error:(NSError *)error
{
    NSLog(@"Failed to delete conversation with error: %@", error);
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSearchForText:(NSString *)searchText completion:(void (^)(NSSet *filteredParticipants))completion
{
    NSLog(@"Searching for text: %@", searchText);
}

#pragma mark - Conversation List View Controller Data Source Methods

- (NSString *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController titleForConversation:(LYRConversation *)conversation
{
    
    if ([conversation.metadata valueForKey:@"title"]){
        return [conversation.metadata valueForKey:@"title"];
    } else {
        return @"Random Group";
    }

}

- (id<ATLAvatarItem>)conversationListViewController:(ATLConversationListViewController *)conversationListViewController avatarItemForConversation:(LYRConversation *)conversation
{
    return [PFUser new];
}


#pragma mark - Actions

- (void)composeButtonTapped:(id)sender
{
    ConversationViewController *controller = [ConversationViewController conversationViewControllerWithLayerClient:self.layerClient];
    controller.displaysAddressBar = YES;
    controller.participants = _usersArray;
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)logoutButtonTapped:(id)sender
{
    NSLog(@"logOutButtonTapAction");
    
    [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        if (!error){
            [PFUser logOut];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            NSLog(@"Failed to deauthenticate: %@", error);
        }
    }];

}

 
@end
