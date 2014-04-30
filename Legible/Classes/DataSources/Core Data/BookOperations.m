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

+(void)saveBookFromContentModel:(KFEpubContentModel*) contentModel epubFilename:(NSString *)epubFilename completionBlock:(void(^)(void)) completion{
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * localContext){
        Book * book = [Book MR_createInContext:localContext];
        book.title = [contentModel metaData][@"title"];
        book.author = [contentModel metaData][@"creator"];
        book.dateAdded = [NSDate date];
        book.filename = epubFilename;
        [localContext MR_saveToPersistentStoreAndWait];
    }completion:^(BOOL success, NSError * error){
        completion();
    }];
}

@end
