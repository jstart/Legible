//
//  LEGEpubChapter.h
//  Legible
//
//  Created by Christopher Truman on 4/4/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LEGEpubChapter : NSObject

@property (nonatomic, strong) NSURL * spineFileURL;

@property (nonatomic, strong) NSNumber * startPageIndex;

@property (nonatomic, strong) NSNumber * numberOfPages;

@property (nonatomic, strong) NSNumber * chapterIndex;

@property (nonatomic, strong) NSMutableArray * pageRangeArray;

@end
