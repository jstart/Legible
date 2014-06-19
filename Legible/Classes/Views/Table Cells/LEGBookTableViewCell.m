//
//  LEGBookTableViewCell.m
//  Legible
//
//  Created by Christopher Truman on 5/2/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import "LEGBookTableViewCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
@implementation LEGBookTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [self.bookTitle setFont:[UIFont fontWithName:@"Montserrat-Regular" size:21]];
    [self.author setFont:[UIFont fontWithName:@"Montserrat-Regular" size:16]];
}

-(void)setBookTitleText:(NSString *)titleText{
    [self.bookTitle setText:titleText];
}

@end
