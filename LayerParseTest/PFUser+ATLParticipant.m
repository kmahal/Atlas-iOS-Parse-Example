//
//  PFUser+Participant.h
//  LayerParseTest
//
//  Created by Abir Majumdar on 3/1/15.
//  Copyright (c) 2015 Abir Majumdar. All rights reserved.
//

#import "PFUser+ATLParticipant.h"

@implementation PFUser (ATLParticipant)

- (NSString *)firstName
{
    return self.username;
}

- (NSString *)lastName
{
    return @"Test";
}

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", self.username, self.lastName];
}

- (NSString *)participantIdentifier
{
    return self.objectId;
}

- (UIImage *)avatarImage
{
    return nil;
}

- (NSString *)avatarInitials
{
    return [[NSString stringWithFormat:@"%@%@", [self.firstName substringToIndex:1], [self.lastName substringToIndex:1]] uppercaseString];
}

@end
