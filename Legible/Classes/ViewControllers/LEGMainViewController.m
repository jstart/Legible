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

@interface LEGMainViewController ()<KFEpubControllerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) KFEpubController * epubController;
@property (nonatomic, strong) UIPageViewController * pageVC;
@property (nonatomic, strong) NSMutableArray * viewControllers;

@end

@implementation LEGMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.viewControllers = [NSMutableArray array];
    
    // Do any additional setup after loading the view.
    NSURL *epubURL = [[NSBundle mainBundle] URLForResource:@"Brad Stone - The Everything Store, Jeff Bezos and the Age of Amazon" withExtension:@"epub"];
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    self.epubController = [[KFEpubController alloc] initWithEpubURL:epubURL andDestinationFolder:documentsURL];
    self.epubController.delegate = self;
    [self.epubController openAsynchronous:YES];
    
    self.pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [self.pageVC.view setFrame:self.view.bounds];
    [self.pageVC.view setBackgroundColor:[UIColor blackColor]];
    [self.pageVC setDelegate:self];
    [self.pageVC setDataSource:self];
    
    [self addChildViewController:self.pageVC];
    [self.view addSubview:self.pageVC.view];
    [self.pageVC didMoveToParentViewController:self];
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
        pageVC = [LEGPageViewController pageViewControllerAtIndex:(index) epubController:self.epubController];
        [self.viewControllers insertObject:pageVC atIndex:index];
    }
    return pageVC;
}

#pragma mark -
#pragma mark KFEpubControllerDelegate

- (void)epubController:(KFEpubController *)controller didOpenEpub:(KFEpubContentModel *)contentModel
{
    LEGPageViewController * pageVC = [LEGPageViewController pageViewControllerAtIndex:0 epubController:self.epubController];
    [self.pageVC setViewControllers:@[pageVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self.viewControllers addObject:pageVC];
}

- (void)epubController:(KFEpubController *)controller didFailWithError:(NSError *)error{
    
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
