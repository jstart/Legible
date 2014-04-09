//
//  LEGPageViewController.m
//  Legible
//
//  Created by Christopher Truman on 4/3/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import "LEGPageViewController.h"

#import <DTCoreText/DTAttributedTextView.h>

#import "LEGEpubContentPager.h"
#import "LEGEpubChapter.h"

@import CoreText;

@interface LEGPageViewController ()

@property (nonatomic, strong) NSTextContainer * textContainer;

@end

@implementation LEGPageViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
        self.textView = [[DTAttributedTextView alloc] initWithFrame:self.view.bounds];
        [self.textContainer setWidthTracksTextView:YES];
//        [self.textView setEditable:NO];
        [self.textView setContentInset:UIEdgeInsetsMake(10, 0, 10, 0)];
        [self.textView setShouldDrawImages:YES];
        
        self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        [self.webView setPaginationBreakingMode:UIWebPaginationBreakingModePage];
        [self.webView setPaginationMode:UIWebPaginationModeLeftToRight];
        [self.webView setSuppressesIncrementalRendering:YES];
        [self.webView.scrollView setPagingEnabled:YES];
        [self.webView.scrollView setShowsVerticalScrollIndicator:NO];
        [self.webView.scrollView setAlwaysBounceVertical:NO];
        [self.webView.scrollView setAlwaysBounceHorizontal:YES];
        [self.webView.scrollView setContentInset:UIEdgeInsetsMake(10, 0, 10, 0)];
        [self.webView setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.view addSubview:self.textView];
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(LEGPageViewController *)pageViewControllerAtIndex:(NSInteger)pageIndex epubContentPager:(LEGEpubContentPager *) epubContentPager size:(CGSize)size {
    __block LEGPageViewController * pageVC = [[LEGPageViewController alloc] init];
    pageVC.textView.alpha = 0.0;
    pageVC.webView.alpha = 0.0;
    pageVC.pageIndex = @(pageIndex);
    __block NSURL * chapterURL = [epubContentPager chapterForPageIndex:pageIndex].spineFileURL;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        __block NSAttributedString * attributedString = [epubContentPager attributedStringForPage:[pageVC.pageIndex integerValue] withChapterURL:chapterURL withSize:size];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [UIView animateWithDuration:0.3 animations:^(){
                [pageVC.textView setAttributedString:attributedString];
                pageVC.textView.alpha = 1.0;
                pageVC.webView.alpha = 1.0;
                NSURLRequest * request = [[NSURLRequest alloc] initWithURL:chapterURL];
                [pageVC.webView loadRequest:request];
            }];
        });
    });
    return pageVC;
}

+(LEGPageViewController *)pageViewControllerAtChapterIndex:(NSInteger)chapterIndex epubContentPager:(LEGEpubContentPager *) epubContentPager size:(CGSize)size {
    __block LEGPageViewController * pageVC = [[LEGPageViewController alloc] init];
    pageVC.webView.alpha = 0.0;
    pageVC.pageIndex = @(chapterIndex);
    __block NSURL * chapterURL = [epubContentPager chapterAtIndex:chapterIndex].spineFileURL;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        dispatch_async(dispatch_get_main_queue(), ^(){
            [UIView animateWithDuration:0.3 animations:^(){
                pageVC.webView.alpha = 1.0;
                NSURLRequest * request = [[NSURLRequest alloc] initWithURL:chapterURL];
                [pageVC.webView loadRequest:request];
            }];
        });
    });
    return pageVC;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
