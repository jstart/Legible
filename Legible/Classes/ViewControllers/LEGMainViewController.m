//
//  LEGMainViewController.m
//  Legible
//
//  Created by Christopher Truman on 4/3/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import "LEGMainViewController.h"

#import <KFEpubKit/KFEpubKit.h>

#import "LEGPageViewController.h"
#import "LEGEpubContentPager.h"
#import "LEGEpubChapter.h"
#import "Book.h"

#define LEG_PAGE_SIZE CGSizeMake(320-10, 568-10)

@interface LEGMainViewController ()<KFEpubControllerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

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
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.pageVC.view addGestureRecognizer:tapGestureRecognizer];
    
    
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL * destinationURL = [documentsURL URLByAppendingPathComponent:self.book.filename];
    
    self.epubController = [[KFEpubController alloc] initWithEPUBContentBaseURL:destinationURL];
    self.epubContentPager = [[LEGEpubContentPager alloc] initWithEpubController:self.epubController];
    
    [self.epubController setDelegate:self];
    [self.epubController openFromUnzippedBaseURL];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

-(void)tap{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
    BOOL statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    [[UIApplication sharedApplication] setStatusBarHidden:!statusBarHidden withAnimation:UIStatusBarAnimationSlide];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(LEGPageViewController *)pageViewControllerForIndex:(NSInteger)index{
    LEGPageViewController * pageVC;
    if ((int)[self.viewControllers count] - 1 >= index) {
        return (LEGPageViewController *)[self.viewControllers objectAtIndex:index];
    }else{
        pageVC = [LEGPageViewController pageViewControllerAtChapterIndex:index epubContentPager:self.epubContentPager size:LEG_PAGE_SIZE];
        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        tapGestureRecognizer.delegate = pageVC;
        [pageVC.webView addGestureRecognizer:tapGestureRecognizer];
        [self.viewControllers insertObject:pageVC atIndex:index];
    }
    return pageVC;
}

#pragma mark -
#pragma mark KFEpubControllerDelegate

- (void)epubController:(KFEpubController *)controller didOpenEpub:(KFEpubContentModel *)contentModel
{
    [self removeAllCSSFilesAtPath:controller.epubContentBaseURL];
    [self.epubContentPager processWithSize:LEG_PAGE_SIZE andProgressBlock:^(LEGEpubChapter * chapter){
        if ([chapter.chapterIndex integerValue] == 0) {
            LEGPageViewController * pageVC = [LEGPageViewController pageViewControllerAtChapterIndex:0 epubContentPager:self.epubContentPager size:LEG_PAGE_SIZE];
            UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
            tapGestureRecognizer.delegate = pageVC;
            [pageVC.webView addGestureRecognizer:tapGestureRecognizer];
            [self.pageVC setViewControllers:@[pageVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            [self.viewControllers addObject:pageVC];
        }
        [self.chapterArray addObject:chapter];
    }];
}

- (void)epubController:(KFEpubController *)controller didFailWithError:(NSError *)error{
    
}

-(void) removeAllCSSFilesAtPath:(NSURL *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:path
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error){
                                                                NSLog(@"[Error] %@ (%@)", error, url);
                                                            return YES;
                                        }];
    
    NSMutableArray *mutableFileURLs = [NSMutableArray array];
    for (NSURL *fileURL in enumerator) {
        NSString *filename;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        
        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        // Skip directories with '_' prefix, for example
        if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
            [enumerator skipDescendants];
            continue;
        }
        
        if (![isDirectory boolValue]) {
            [mutableFileURLs addObject:fileURL];
        }
        if ([filename hasSuffix:@".css"]) {
            [fileManager removeItemAtURL:fileURL error:nil];
        }
    }
}

#pragma mark -
#pragma mark UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    LEGPageViewController * pageVCBefore = (LEGPageViewController *)viewController;

    if ([pageVCBefore.pageIndex integerValue] == 0) {
        return nil;
    }
    int newPageIndex = 0;
    LEGPageViewController * pageVC;
    if (viewController != nil) {
        newPageIndex = (int) [pageVCBefore.pageIndex integerValue] - 1;
        pageVC = [self pageViewControllerForIndex:(newPageIndex)];
    }

    return pageVC;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    LEGPageViewController * pageVCAfter = (LEGPageViewController *)viewController;
    if ([pageVCAfter.pageIndex integerValue] + 1 >= (int)[self.epubController.contentModel.spine count]) {
        return nil;
    }
    int newPageIndex = (int) [pageVCAfter.pageIndex integerValue] + 1;
   LEGPageViewController *  pageVC = [self pageViewControllerForIndex:(newPageIndex)];
    
    return pageVC;
}

#pragma mark -
#pragma mark UIPageViewControllerDelegate

// Sent when a gesture-initiated transition begins.
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers{
    
}

// Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished, while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    if (finished && completed) {
        LEGPageViewController * pageVC = [self.pageVC.viewControllers lastObject];
        NSLog(@"%@", pageVC.pageIndex);
    }
}

- (NSUInteger)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController NS_AVAILABLE_IOS(7_0){
    return UIInterfaceOrientationMaskAll;
}

@end
