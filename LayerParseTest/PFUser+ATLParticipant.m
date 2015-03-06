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
    return @"";
}

- (NSString *)fullName
{
    return self.username;
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
    return [self.username substringToIndex:1];
}

@end
