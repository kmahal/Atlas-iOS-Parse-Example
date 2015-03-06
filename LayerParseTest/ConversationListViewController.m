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

@interface ConversationListViewController () <ATLConversationListViewControllerDelegate, ATLConversationListViewControllerDataSource>

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
}

#pragma mark - Conversation List View Controller Delegate Methods

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation
{
    ConversationViewController *controller = [ConversationViewController conversationViewControllerWithLayerClient:self.layerClient];
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
    /*
    if (!self.layerClient.authenticatedUserID) return @"Not auth'd";
    NSSet *participants = conversation.participants;
    
    // Remove authenticatedUserID from list of participants
    NSMutableSet *mutableSet = [NSMutableSet setWithSet:participants];
    [mutableSet removeObject:self.layerClient.authenticatedUserID];
    participants = mutableSet;
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" containedIn:participants.allObjects];
    NSArray *participantsInConversations = [query findObjects];

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSArray *sortedArray=[participantsInConversations sortedArrayUsingDescriptors:@[sort]];
    
    NSString * result = [[sortedArray valueForKey:@"firstName"] componentsJoinedByString:@","];
    return result;
    */
    return nil;
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
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)logoutButtonTapped:(id)sender
{
    NSLog(@"logOutButtonTapAction");
    [PFUser logOut];
    [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Failed to deauthenticate: %@", error);
        } else {
            NSLog(@"Previous user deauthenticated");
        }
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

 
@end
