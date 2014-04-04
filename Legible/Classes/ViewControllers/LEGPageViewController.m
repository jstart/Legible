//
//  LEGPageViewController.m
//  Legible
//
//  Created by Christopher Truman on 4/3/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import "LEGPageViewController.h"

#import <KFEpubKit/KFEpubKit.h>
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
        self.textView = [[UITextView alloc] initWithFrame:self.view.bounds textContainer:self.textContainer];
        [self.textView setEditable:NO];
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
    [self.view addSubview:self.textView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(LEGPageViewController *)pageViewControllerAtIndex:(NSInteger)pageIndex epubController:(KFEpubController *) epubController{
    LEGPageViewController * pageVC = [[LEGPageViewController alloc] init];
    pageVC.pageIndex = @(pageIndex);
    
    NSString *contentFile = epubController.contentModel.manifest[epubController.contentModel.spine[pageIndex]][@"href"];
    NSURL *contentURL = [epubController.epubContentBaseURL URLByAppendingPathComponent:contentFile];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithFileURL:contentURL options:nil documentAttributes:nil error:nil];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(attributedString)); /*Create your framesetter based in you NSAttrinbutedString*/
    CGFloat widthConstraint = 300; // Your width constraint, using 500 as an example
    CFRange range;
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
                                                                        frameSetter, /* Framesetter */
                                                                        CFRangeMake(0, attributedString.length), /* String range (entire string) */
                                                                        NULL, /* Frame attributes */
                                                                        CGSizeMake(widthConstraint, 568), /* Constraints (CGFLOAT_MAX indicates unconstrained) */
                                                                        &range /* Gives the range of string that fits into the constraints, doesn't matter in your situation */
                                                                        );

    NSRange rangeFormatted = NSMakeRange(range.location, range.length);
    NSLog(@"%lu %lu, %f %f", (unsigned long)rangeFormatted.location, (unsigned long)rangeFormatted.length, suggestedSize.width, suggestedSize.height);
    
    
    [pageVC.textView setAttributedText:[attributedString attributedSubstringFromRange:rangeFormatted]];
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
