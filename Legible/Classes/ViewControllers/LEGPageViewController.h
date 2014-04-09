//
//  LEGPageViewController.h
//  Legible
//
//  Created by Christopher Truman on 4/3/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LEGEpubContentPager, LEGEpubChapter, DTAttributedTextView;

@interface LEGPageViewController : UIViewController

@property (nonatomic, strong) DTAttributedTextView * textView;
@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) NSNumber * pageIndex;

+(LEGPageViewController *)pageViewControllerAtIndex:(NSInteger)pageIndex epubContentPager:(LEGEpubContentPager *) epubContentPager size:(CGSize)size;
+(LEGPageViewController *)pageViewControllerAtChapterIndex:(NSInteger)chapterIndex epubContentPager:(LEGEpubContentPager *) epubContentPager size:(CGSize)size;

@end
