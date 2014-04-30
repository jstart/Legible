//
//  BookOperations.h
//  Legible
//
//  Created by Christopher Truman on 4/28/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

@class KFEpubContentModel;

@interface BookOperations : NSObject 

+(void)saveAllBooks:(NSArray *) books withCompletionBlock:(void(^)(void)) completion;

+(void)saveBookFromContentModel:(KFEpubContentModel*) contentModel epubFileName:(NSString *)epubFileName epubContentBaseURL:(NSString *)epubContentBaseURL completionBlock:(void(^)(void)) completion;

@end
