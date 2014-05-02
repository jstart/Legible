//
//  BookOperations.h
//  Legible
//
//  Created by Christopher Truman on 4/28/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

@class KFEpubContentModel;
@class Book;

@interface BookOperations : NSObject 

+(void)saveAllBooks:(NSArray *) books withCompletionBlock:(void(^)(void)) completion;

+(void)saveBookFromContentModel:(KFEpubContentModel*) contentModel epubFileName:(NSString *)epubFileName epubContentBaseURL:(NSString *)epubContentBaseURL completionBlock:(void(^)(void)) completion;

+(void)setLastChapterIndex:(NSNumber *) lastChapter forBook:(Book *)book;

+(void)setLastPageIndex:(NSNumber *) lastPage forBook:(Book *)book;

@end
