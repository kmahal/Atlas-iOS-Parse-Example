//
//  ConversationViewController.m
//  LayerParseTest
//
//  Created by Abir Majumdar on 2/28/15.
//
//

#import "ConversationViewController.h"
#import "ParticipantTableViewController.h"

@interface ConversationViewController () <ATLConversationViewControllerDataSource, ATLConversationViewControllerDelegate, ATLParticipantTableViewControllerDelegate>

@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation ConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
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
    return [PFUser currentUser];
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

#pragma mark - ATLConversationViewControllerDataSource methods

- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" notEqualTo:self.layerClient.authenticatedUserID]; // find all the women
    [query findObjectsInBackgroundWithBlock:^(NSArray *allUsersArray, NSError *error) {
        
        if(!error){
            NSSet *allUsersSet = [NSSet setWithArray:allUsersArray];
            
            ParticipantTableViewController *controller = [ParticipantTableViewController participantTableViewControllerWithParticipants:allUsersSet sortType:ATLParticipantPickerSortTypeFirstName];
            controller.delegate = self;
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        }
        
    }];
}

- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<ATLParticipant>)participant
{    
    NSLog(@"participant: %@", participant);
    [self.addressBarController selectParticipant:participant];
    NSLog(@"selectedParticipants: %@", [self.addressBarController selectedParticipants]);
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    NSLog(@"Searching for text: %@", searchText);    
}

@end
