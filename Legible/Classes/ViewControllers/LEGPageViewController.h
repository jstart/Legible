//
//  LEGPageViewController.h
//  Legible
//
//  Created by Christopher Truman on 4/3/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KFEpubController;

@interface LEGPageViewController : UIViewController

@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, strong) NSNumber * pageIndex;

+(LEGPageViewController *)pageViewControllerAtIndex:(NSInteger)pageIndex epubController:(KFEpubController *) epubController;

@end
