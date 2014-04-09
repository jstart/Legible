//
//  LEGEpubContentPager.h
//  Legible
//
//  Created by Christopher Truman on 4/3/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KFEpubController, LEGEpubChapter;

@interface LEGEpubContentPager : NSObject

@property (nonatomic, strong) KFEpubController *epubController;

- (instancetype)initWithEpubController:(KFEpubController *)epubController;

- (void)processWithSize:(CGSize)size andProgressBlock:(void (^)(LEGEpubChapter * chapter))progressBlock;

- (NSAttributedString *)attributedStringForPage:(NSInteger)pageIndex withChapterURL:(NSURL *)chapterURL withSize:(CGSize)size;

- (int)numberOfPagesForSize:(CGSize)size;

- (LEGEpubChapter *)chapterForPageIndex:(NSInteger)pageIndex;

- (LEGEpubChapter *)chapterAtIndex:(NSInteger)chapterIndex;

@end
