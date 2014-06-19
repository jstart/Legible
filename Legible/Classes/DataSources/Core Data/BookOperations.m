//
//  BookOperations.m
//  Legible
//
//  Created by Christopher Truman on 4/28/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import "BookOperations.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <KFEPubKit/KFEpubContentModel.h>
#import "Book.h"

@implementation BookOperations

+(void)saveAllBooks:(NSArray *) books withCompletionBlock:(void(^)(void)) completion{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * localContext){
        NSMutableArray * bookLocalContextArray = [NSMutableArray array];
        for (Book * book in books) {
            [bookLocalContextArray addObject:[book MR_inContext:localContext]];
        }
        [localContext save:nil];
    }completion:^(BOOL success, NSError * error){
        completion();
    }];
}

+(void)saveBookFromContentModel:(KFEpubContentModel*) contentModel epubFileName:(NSString *)epubFileName epubContentBaseURL:(NSString *)epubContentBaseURL completionBlock:(void(^)(void)) completion{
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * localContext){
        Book * book = [Book MR_createInContext:localContext];
        book.title = [contentModel metaData][@"title"];
        book.author = [contentModel metaData][@"creator"];
        book.dateAdded = [NSDate date];
        book.filename = epubFileName;
        book.epubContentBaseURL = epubContentBaseURL;
        book.lastChapter = @(0);
        book.lastPage = @(0);
        [localContext MR_saveToPersistentStoreAndWait];
    }completion:^(BOOL success, NSError * error){
        completion();
    }];
}

+(void)setLastChapterIndex:(NSNumber *) lastChapter forBook:(Book *)book{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * localContext){
        Book * localBook = [book MR_inContext:localContext];
        localBook.lastChapter = lastChapter;
    }completion:^(BOOL success, NSError * error){
        
    }];
}

+(void)setLastPageIndex:(NSNumber *) lastPage forBook:(Book *)book{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * localContext){
        Book * localBook = [book MR_inContext:localContext];
        localBook.lastPage = lastPage;
    }completion:^(BOOL success, NSError * error){
        
    }];
}

@end
