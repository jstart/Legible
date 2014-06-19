//
//  LEGBookTableViewCell.h
//  Legible
//
//  Created by Christopher Truman on 5/2/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LEGBookTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *bookTitle;
@property (weak, nonatomic) IBOutlet UILabel *author;

-(void)setBookTitleText:(NSString *)titleText;

@end
