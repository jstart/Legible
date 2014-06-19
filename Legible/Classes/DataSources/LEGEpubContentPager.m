//
//  LEGEpubContentPager.m
//  Legible
//
//  Created by Christopher Truman on 4/3/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import "LEGEpubContentPager.h"

@import CoreText;

#import "KFEpubConstants.h"
#import "KFEpubController.h"
#import "KFEpubContentModel.h"
#import "LEGEpubChapter.h"
#import <DTCoreText/NSAttributedString+HTML.h>
#import <DTCoreText/DTCoreTextConstants.h>

@interface LEGEpubContentPager ()

@property (nonatomic, strong) NSMutableArray * pageRangeArray;
@property (nonatomic, strong) NSAttributedString * allTextAttributedString;
@property (nonatomic, strong) NSMutableArray * chapterArray;
@property (nonatomic, strong) NSMutableArray * spineArray;

@end

@implementation LEGEpubContentPager

- (instancetype)initWithEpubController:(KFEpubController *)epubController
{
    self = [super init];
    if (self)
    {
        self.epubController = epubController;
        self.pageRangeArray = [NSMutableArray array];
        self.chapterArray = [NSMutableArray array];
    }
    return self;
}

- (LEGEpubChapter *)chapterForPageIndex:(NSInteger)pageIndex{
    for (LEGEpubChapter * aChapter in self.chapterArray) {
        NSRange range = NSMakeRange([aChapter.startPageIndex integerValue], [aChapter.numberOfPages integerValue]);
        
        if (NSLocationInRange(pageIndex, range)) {
            return aChapter;
        }
    }
    return nil;
}

- (LEGEpubChapter *)chapterAtIndex:(NSInteger)chapterIndex{
    
    if (!self.spineArray) {
        self.spineArray = [self.epubController.contentModel.spine mutableCopy];
    }
    LEGEpubChapter * chapter = [LEGEpubChapter new];
    
    NSString *contentFile = self.epubController.contentModel.manifest[self.spineArray[chapterIndex]][@"href"];
    if ([[contentFile pathExtension] isEqualToString:@"ncx"]) {
        [self.spineArray removeObject:self.spineArray[chapterIndex]];
        contentFile = self.epubController.contentModel.manifest[self.spineArray[chapterIndex]][@"href"];
    }
    NSURL *contentURL = [self.epubController.epubContentBaseURL URLByAppendingPathComponent:contentFile];
    chapter.spineFileURL = contentURL;
    return chapter;
}

- (void)processWithSize:(CGSize)size andCompletionBlock:(void (^)(NSArray * chapterArray))completionBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
//        NSInteger totalPageNumber = 0;
        NSInteger chapterIndex = 0;
        for (NSString * spineKey in self.epubController.contentModel.spine) {
            @autoreleasepool {
                if ([spineKey isEqualToString:@"ncx"]) {
                    continue;
                }
//                NSMutableArray * pageRangeArray = [NSMutableArray array];
                LEGEpubChapter * chapter = [LEGEpubChapter new];
                
                NSString *contentFile = self.epubController.contentModel.manifest[spineKey][@"href"];
                NSURL *contentURL = [self.epubController.epubContentBaseURL URLByAppendingPathComponent:contentFile];
                chapter.spineFileURL = contentURL;
                
//                chapter.startPageIndex = @(totalPageNumber);
//                
//                NSAttributedString *attributedString = [self attributedStringAtURL:contentURL];
//
//                NSInteger chapterPageNumber = 0;
//                NSInteger currentChapterCharacterIndex = 0;
//                while (attributedString.length) {
//                    NSRange range = [self rangeForAttributedString:attributedString withSize:size];
//                    NSRange rangeToStore = NSMakeRange(currentChapterCharacterIndex, range.length);
//                    [pageRangeArray addObject:[NSValue valueWithRange:rangeToStore]];
//                    currentChapterCharacterIndex += range.length;
//                    
//                    NSRange remainingRange = NSMakeRange(range.location+range.length, attributedString.length - (range.location+range.length));
//                    attributedString = [attributedString attributedSubstringFromRange:remainingRange];
//                    chapterPageNumber++;
//                    totalPageNumber++;
//                }
                chapter.chapterIndex = @(chapterIndex);
//                chapter.pageRangeArray = pageRangeArray;
//                chapter.numberOfPages = @(chapterPageNumber);
                [self.chapterArray addObject:chapter];
                chapterIndex++;

            }
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            completionBlock(self.chapterArray);
        });
    });

}

-(NSAttributedString *)attributedStringAtURL:(NSURL*) url{
    NSData * htmlData = [NSData dataWithContentsOfURL:url];
    NSDictionary *options = @{DTUseiOS6Attributes: [NSNumber numberWithBool:YES], NSBaseURLDocumentOption: self.epubController.epubContentBaseURL};
    NSAttributedString * attributedString = [[NSAttributedString alloc] initWithHTMLData:htmlData options:options documentAttributes:NULL];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    NSDictionary *attributes = @{
                                 NSParagraphStyleAttributeName : paragraphStyle,
                                 };
    NSRange totalRange = NSMakeRange(0, attributedString.length);
    NSMutableAttributedString * newAttributedString = [attributedString mutableCopy];
    [newAttributedString setAttributes:attributes range:totalRange];
    return newAttributedString;
}

- (NSAttributedString *)attributedStringForPage:(NSInteger)pageIndex withChapterURL:(NSURL *)chapterURL withSize:(CGSize)size{
    NSAttributedString * attributedString = [self attributedStringAtURL:chapterURL];
    NSRange range = [self rangeForPageIndex:pageIndex];
    
    attributedString = [attributedString attributedSubstringFromRange:range];

    return attributedString;
}

-(NSRange)rangeForPageIndex:(NSInteger)pageIndex{
    LEGEpubChapter * chapter = [self chapterForPageIndex:pageIndex];
    pageIndex -= [chapter.startPageIndex integerValue];
    NSRange range = [[chapter.pageRangeArray objectAtIndex:pageIndex] rangeValue];
    return range;
}

-(NSRange)rangeForAttributedString:(NSAttributedString *)attributedString withSize:(CGSize)size{
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(attributedString)); /* Create your framesetter based on your NSAttributedString */
    CFRange range;
    CTFramesetterSuggestFrameSizeWithConstraints(
                                                                        frameSetter, /* Framesetter */
                                                                        CFRangeMake(0, attributedString.length), /* String range (entire string) */
                                                                        NULL, /* Frame attributes */
                                                                        size, /* Constraints (CGFLOAT_MAX indicates unconstrained) */
                                                                        &range /* Gives the range of string that fits into the constraints */
                                                                        );
    CFRelease(frameSetter);
    
    NSRange rangeFormatted = NSMakeRange(range.location, range.length);
    return rangeFormatted;
}

//- (int)numberOfPagesForSize:(CGSize)size{
//    NSAttributedString * allText = [self attributedStringForAllText];
//    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(allText)); /* Create your framesetter based on your NSAttributedString */
//    
//    CGSize framesetterSize = CGSizeMake(size.width, CGFLOAT_MAX);
//    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
//                                                                        frameSetter, /* Framesetter */
//                                                                        CFRangeMake(0, allText.length), /* String range (entire string) */
//                                                                        NULL, /* Frame attributes */
//                                                                        framesetterSize, /* Constraints (CGFLOAT_MAX indicates unconstrained) */
//                                                                        nil /* Gives the range of string that fits into the constraints */
//                                                                        );
//    CFRelease(frameSetter);
//    
//    int numPages = (int)ceil(suggestedSize.height/size.height);
//    return numPages;
//}

@end
