//
//  LEGChapterViewController.m
//  Legible
//
//  Created by Christopher Truman on 4/3/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import "LEGChapterViewController.h"

#import <DTCoreText/DTAttributedTextView.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "LEGEpubContentPager.h"
#import "LEGEpubChapter.h"

@import CoreText;

@interface LEGChapterViewController () <UIScrollViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong) NSTextContainer * textContainer;

@end

@implementation LEGChapterViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
//        self.textView = [[DTAttributedTextView alloc] initWithFrame:self.view.bounds];
//        [self.textContainer setWidthTracksTextView:YES];
//        [self.textView setEditable:NO];
//        [self.textView setContentInset:UIEdgeInsetsMake(10, 0, 10, 0)];
//        [self.textView setShouldDrawImages:YES];
        self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
        self.webView.scrollView.backgroundColor = [UIColor whiteColor];
        self.webView.backgroundColor = [UIColor whiteColor];
        [self.webView setDelegate:self];
        [self.webView setPaginationBreakingMode:UIWebPaginationBreakingModeColumn];
        [self.webView setPaginationMode:UIWebPaginationModeLeftToRight];
        [self.webView setSuppressesIncrementalRendering:YES];
        [self.webView.scrollView setPagingEnabled:YES];
        [self.webView.scrollView setShowsVerticalScrollIndicator:NO];
        [self.webView.scrollView setAlwaysBounceVertical:NO];
        [self.webView.scrollView setAlwaysBounceHorizontal:YES];
        [self.webView.scrollView setContentInset:UIEdgeInsetsMake(10, 0, 10, 0)];
        
        [self.webView setBackgroundColor:[UIColor whiteColor]];
        
        [self.webView.scrollView setDelegate:self];
        
        self.automaticallyAdjustsScrollViewInsets = NO;
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
    if (self.webView.superview == nil) {
        [self.view addSubview:self.webView];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.webView.scrollView.contentOffset = CGPointZero;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
}

-(void)scrollToPage:(NSNumber *)pageNumber{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat contentOffset = [pageNumber floatValue] * screenSize.width;
    CGRect pageRect = CGRectMake(contentOffset, -10, screenSize.width, screenSize.height-10);
    [self.webView.scrollView scrollRectToVisible:pageRect animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(LEGChapterViewController *)pageViewControllerAtIndex:(NSInteger)pageIndex epubContentPager:(LEGEpubContentPager *) epubContentPager size:(CGSize)size {
    __block LEGChapterViewController * pageVC = [[LEGChapterViewController alloc] init];
//    pageVC.textView.alpha = 0.0;
    pageVC.webView.alpha = 0.0;
    pageVC.chapterIndex = @(pageIndex);
    __block NSURL * chapterURL = [epubContentPager chapterForPageIndex:pageIndex].spineFileURL;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        __block NSAttributedString * attributedString = [epubContentPager attributedStringForPage:[pageVC.chapterIndex integerValue] withChapterURL:chapterURL withSize:size];
        dispatch_async(dispatch_get_main_queue(), ^(){
                [pageVC.textView setAttributedString:attributedString];
                pageVC.webView.alpha = 1.0;
                NSURLRequest * request = [[NSURLRequest alloc] initWithURL:chapterURL];
                [pageVC.webView loadRequest:request];
        });
    });
    return pageVC;
}

+(LEGChapterViewController *)chapterViewControllerAtIndex:(NSInteger)chapterIndex epubContentPager:(LEGEpubContentPager *) epubContentPager size:(CGSize)size {
    __block LEGChapterViewController * pageVC = [[LEGChapterViewController alloc] init];
    pageVC.webView.alpha = 0.0;
    pageVC.chapterIndex = @(chapterIndex);
    __block NSURL * chapterURL = [epubContentPager chapterAtIndex:chapterIndex].spineFileURL;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        dispatch_async(dispatch_get_main_queue(), ^(){
                NSURLRequest * request = [[NSURLRequest alloc] initWithURL:chapterURL];
                [pageVC.webView loadRequest:request];
        });
    });
    return pageVC;
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int pageNum = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
    self.currentPageNumber = @(pageNum);
}

#pragma mark -
#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [UIView animateWithDuration:0.3 animations:^(){
        webView.alpha = 1.0;
        if (self.pageToScrollTo) {
            [self scrollToPage:self.pageToScrollTo];
            self.pageToScrollTo = nil;
        }
    }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{

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
