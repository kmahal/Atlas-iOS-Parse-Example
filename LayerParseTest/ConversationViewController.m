//
//  ConversationViewController.m
//  LayerParseTest
//
//  Created by Abir Majumdar on 2/28/15.
//
//

#import "ConversationViewController.h"
#import "ParticipantTableViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>

@interface ConversationViewController () <ATLConversationViewControllerDataSource, ATLConversationViewControllerDelegate, ATLParticipantTableViewControllerDelegate>

@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSArray *usersArray;

@end

@implementation ConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    self.addressBarController.delegate = self;
    
    // Setup the dateformatter used by the dataSource.
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;

    [self configureUI];
}

#pragma mark - UI Configuration methods

- (void)configureUI
{
    [[ATLOutgoingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor whiteColor]];
}

#pragma mark - ATLConversationViewControllerDelegate methods

- (void)conversationViewController:(ATLConversationViewController *)viewController didSendMessage:(LYRMessage *)message
{
    NSLog(@"Message sent!");
}

- (void)conversationViewController:(ATLConversationViewController *)viewController didFailSendingMessage:(LYRMessage *)message error:(NSError *)error
{
    NSLog(@"Message failed to sent with error: %@", error);
}

- (void)conversationViewController:(ATLConversationViewController *)viewController didSelectMessage:(LYRMessage *)message
{
    NSLog(@"Message selected");
}

#pragma mark - ATLConversationViewControllerDataSource methods

- (id<ATLParticipant>)conversationViewController:(ATLConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier
{
    PFUser *user = [self localQueryForUserID:participantIdentifier];
    return user;
}

- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date
{
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor grayColor] };
    return [[NSAttributedString alloc] initWithString:[self.dateFormatter stringFromDate:date] attributes:attributes];
}

- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus
{
    if (recipientStatus.count == 0) return nil;
    NSMutableAttributedString *mergedStatuses = [[NSMutableAttributedString alloc] init];

    [[recipientStatus allKeys] enumerateObjectsUsingBlock:^(NSString *participant, NSUInteger idx, BOOL *stop) {
        LYRRecipientStatus status = [recipientStatus[participant] unsignedIntegerValue];
        if ([participant isEqualToString:self.layerClient.authenticatedUserID]) {
            return;
        }

        NSString *checkmark = @"✔︎";
        UIColor *textColor = [UIColor lightGrayColor];
        if (status == LYRRecipientStatusSent) {
            textColor = [UIColor lightGrayColor];
        } else if (status == LYRRecipientStatusDelivered) {
            textColor = [UIColor orangeColor];
        } else if (status == LYRRecipientStatusRead) {
            textColor = [UIColor greenColor];
        }
        NSAttributedString *statusString = [[NSAttributedString alloc] initWithString:checkmark attributes:@{NSForegroundColorAttributeName: textColor}];
        [mergedStatuses appendAttributedString:statusString];
    }];
    return mergedStatuses;
}

#pragma mark - ATLAddressBarViewController Delegate methods methods

- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton
{
    [self localQueryForAllUsersWithCompletion:^(NSArray *users) {
        ParticipantTableViewController *controller = [ParticipantTableViewController participantTableViewControllerWithParticipants:[NSSet setWithArray:users] sortType:ATLParticipantPickerSortTypeFirstName];
        controller.delegate = self;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }];
}

-(void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSArray *))completion
{
    [self localQueryForUserWithName:searchText completion:^(NSArray *participants) {
        if (completion) completion(participants);
    }];
}

#pragma mark - ATLParticipantTableViewController Delegate Methods

- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<ATLParticipant>)participant
{    
    NSLog(@"participant: %@", participant);
    [self.addressBarController selectParticipant:participant];
    NSLog(@"selectedParticipants: %@", [self.addressBarController selectedParticipants]);
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    [self localQueryForUserWithName:searchText completion:^(NSArray *participants) {
        if (completion) completion([NSSet setWithArray:participants]);
    }];
}

#pragma mark - Data Source Methods

- (void)localQueryForUserWithName:(NSString*)searchText completion:(void (^)(NSArray *participants))completion
{
    PFQuery *query = [PFUser query];
    [query fromLocalDatastore];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *contacts = [NSMutableArray new];
        for (PFUser *user in objects){
            if ([user.fullName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [contacts addObject:user];
            }
        }
        if (completion) completion([NSArray arrayWithArray:contacts]);
    }];

}

- (void)localQueryForUserID:(NSString*)userID completion:(void (^)(PFUser *user))completion
{
    PFQuery *query = [PFUser query];
    [query fromLocalDatastore];
    
    [query getObjectInBackgroundWithId:userID block:^(PFObject *object, NSError *error) {
        if (!error){
            if (completion) completion((PFUser*)object);
        }
    }];
}

- (PFUser *)localQueryForUserID:(NSString*)userID
{
    PFQuery *query = [PFUser query];
    [query fromLocalDatastore];
    
    PFUser *user = (PFUser*)[query getObjectWithId:userID];
    
    return user;

}

- (void)localQueryForAllUsersWithCompletion:(void (^)(NSArray *users))completion
{
    PFQuery *query = [PFUser query];
    [query fromLocalDatastore];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (completion) completion(objects);
    }];
}

@end
