//
//  LEGMainViewController.m
//  Legible
//
//  Created by Christopher Truman on 4/3/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import "LEGMainViewController.h"

#import <KFEpubKit/KFEpubKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "LEGChapterViewController.h"
#import "LEGEpubContentPager.h"
#import "LEGEpubChapter.h"
#import "Book.h"
#import "BookOperations.h"

#define LEG_PAGE_SIZE CGSizeMake(320-10, 568-10)

@interface LEGMainViewController ()<KFEpubControllerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) KFEpubController * epubController;
@property (nonatomic, strong) UIPageViewController * pageVC;
@property (nonatomic, strong) NSMutableArray * viewControllers;
@property (nonatomic, strong) LEGEpubContentPager * epubContentPager;
@property (nonatomic, strong) NSMutableArray * chapterArray;
@property (nonatomic, strong) NSNumber * currentChapterIndex;
@property (nonatomic, strong) Book * book;

@end

@implementation LEGMainViewController

-(instancetype)initWithBook:(Book *)book
{
    self = [super init];
    if (self) {
        self.book = book;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.viewControllers = [NSMutableArray array];
    self.chapterArray = [NSMutableArray array];
    self.currentChapterIndex = @(0);
    
    self.pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [self.pageVC.view setFrame:self.view.bounds];
    [self.pageVC.view setBackgroundColor:[UIColor blackColor]];
    [self.pageVC setDelegate:self];
    [self.pageVC setDataSource:self];
    
    [self addChildViewController:self.pageVC];
    [self.view addSubview:self.pageVC.view];
    [self.pageVC didMoveToParentViewController:self];
    
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL * destinationURL = [documentsURL URLByAppendingPathComponent:self.book.filename];
    

    self.epubController = [[KFEpubController alloc] initWithEPUBContentBaseURL:[NSURL URLWithString:self.book.epubContentBaseURL] andEpubURL:destinationURL];
    self.epubContentPager = [[LEGEpubContentPager alloc] initWithEpubController:self.epubController];
    
    [self.epubController setDelegate:self];
    [self.epubController openFromUnzippedBaseURL];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

-(void)addGestureRecognizersToPageViewController:(LEGChapterViewController *)pageVC{
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavBar)];
    tapGestureRecognizer.delegate = self;
    [pageVC.view addGestureRecognizer:tapGestureRecognizer];
    
    UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(hideNavBar)];
    panGestureRecognizer.delegate = self;
    [pageVC.view addGestureRecognizer:panGestureRecognizer];
}

-(void)showHideNavBar{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
    BOOL statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    [[UIApplication sharedApplication] setStatusBarHidden:!statusBarHidden withAnimation:UIStatusBarAnimationFade];
}

-(void)hideNavBar{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(LEGChapterViewController *)pageViewControllerForChapterIndex:(NSInteger)index{
    LEGChapterViewController * chapterVC;
    if ((int)[self.viewControllers count] - 1 >= index) {
        return (LEGChapterViewController *)[self.viewControllers objectAtIndex:index];
    }else{
        chapterVC = [LEGChapterViewController pageViewControllerAtChapterIndex:index epubContentPager:self.epubContentPager size:LEG_PAGE_SIZE];
        [self subscribeToCurrentPage:chapterVC];
        [self addGestureRecognizersToPageViewController:chapterVC];
        [self.viewControllers insertObject:chapterVC atIndex:index];
    }
    return chapterVC;
}

-(void)subscribeToCurrentPage:(LEGChapterViewController *)chapterVC{
    [RACObserve(chapterVC, currentPageNumber) subscribeNext:^(NSNumber *newNumber) {
        [BookOperations setLastPageIndex:newNumber forBook:self.book];
    }];
}

#pragma mark -
#pragma mark KFEpubControllerDelegate

- (void)epubController:(KFEpubController *)controller didOpenEpub:(KFEpubContentModel *)contentModel
{
    [self.epubContentPager processWithSize:LEG_PAGE_SIZE andProgressBlock:^(LEGEpubChapter * chapter){
        if ([chapter.chapterIndex integerValue] == 0) {
            LEGChapterViewController * chapterVC = [LEGChapterViewController pageViewControllerAtChapterIndex:0 epubContentPager:self.epubContentPager size:LEG_PAGE_SIZE];
            [self subscribeToCurrentPage:chapterVC];
            [self addGestureRecognizersToPageViewController:chapterVC];
            [self.pageVC setViewControllers:@[chapterVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            [self.viewControllers addObject:chapterVC];
            [self.chapterArray addObject:chapter];
        }
        [self.chapterArray addObject:chapter];
    }];
}

- (void)epubController:(KFEpubController *)controller didFailWithError:(NSError *)error{
    
}

#pragma mark -
#pragma mark UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    LEGChapterViewController * pageVCBefore = (LEGChapterViewController *)viewController;

    if ([pageVCBefore.chapterIndex integerValue] == 0) {
        return nil;
    }
    int newPageIndex = 0;
    LEGChapterViewController * chapterVC;
    if (viewController != nil) {
        newPageIndex = (int) [pageVCBefore.chapterIndex integerValue] - 1;
        chapterVC = [self pageViewControllerForChapterIndex:(newPageIndex)];
    }
    CGSize webContentSize = chapterVC.webView.scrollView.contentSize;
    CGRect lastPageRect = CGRectMake(webContentSize.width-320, 0, 320, [UIScreen mainScreen].bounds.size.height);
    [chapterVC.webView.scrollView scrollRectToVisible:lastPageRect animated:NO];

    return chapterVC;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    LEGChapterViewController * pageVCAfter = (LEGChapterViewController *)viewController;
    if ([pageVCAfter.chapterIndex integerValue] + 1 == (int)[self.chapterArray count] - 1) {
        return nil;
    }else{
        [self pageViewControllerForChapterIndex:([pageVCAfter.chapterIndex integerValue]) + 1];
    }
    int nextChapterIndex = (int) [pageVCAfter.chapterIndex integerValue] + 1;
    LEGChapterViewController *  pageVC = [self pageViewControllerForChapterIndex:(nextChapterIndex)];
    return pageVC;
}


#pragma mark -
#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark -
#pragma mark UIPageViewControllerDelegate

// Sent when a gesture-initiated transition begins.
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers{
    
}

// Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished, while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    if (finished && completed) {
        LEGChapterViewController * chapterVC = [self.pageVC.viewControllers lastObject];
        self.currentChapterIndex = chapterVC.chapterIndex;
        NSLog(@"%@", chapterVC.chapterIndex);
        [BookOperations setLastChapterIndex:self.currentChapterIndex forBook:self.book];
    }
}

- (NSUInteger)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController NS_AVAILABLE_IOS(7_0){
    return UIInterfaceOrientationMaskAll;
}

@end
