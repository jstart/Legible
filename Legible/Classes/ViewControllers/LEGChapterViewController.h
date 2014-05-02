//
//  LEGChapterViewController.h
//  Legible
//
//  Created by Christopher Truman on 4/3/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LEGEpubContentPager, LEGEpubChapter, DTAttributedTextView;

@interface LEGChapterViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) DTAttributedTextView * textView;
@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) NSNumber * chapterIndex;
@property (nonatomic, strong) NSNumber * currentPageNumber;

+(LEGChapterViewController *)pageViewControllerAtIndex:(NSInteger)pageIndex epubContentPager:(LEGEpubContentPager *) epubContentPager size:(CGSize)size;
+(LEGChapterViewController *)pageViewControllerAtChapterIndex:(NSInteger)chapterIndex epubContentPager:(LEGEpubContentPager *) epubContentPager size:(CGSize)size;

@end
