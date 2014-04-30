//
//  LEGEpubDataSource.h
//  Legible
//
//  Created by Christopher Truman on 4/3/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

@class Book;

@interface LEGEpubDataSource : NSObject

/**
 * gets singleton object.
 * @return singleton
 */
+ (LEGEpubDataSource*)sharedInstance;

- (void)serializeEPUBFileAtURL:(NSURL *)epubFileURL completion:(void(^)(void)) completion;

@end
