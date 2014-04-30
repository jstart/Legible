//
//  LEGEpubDataSource.m
//  Legible
//
//  Created by Christopher Truman on 4/3/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import "LEGEpubDataSource.h"
#import <KFEpubKit/KFEpubController.h>
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "BookOperations.h"

@interface LEGEpubDataSource ()

@property (nonatomic, strong) KFEpubController * epubController;

@end

@implementation LEGEpubDataSource

static LEGEpubDataSource *sharedInstance = nil;

#pragma mark - Public Method

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL]init];
    });
    
    return sharedInstance;
}

- (void)serializeEPUBFileAtURL:(NSURL *)epubFileURL completion:(void(^)(void)) completion{
    __block NSString * epubFileName = [[epubFileURL lastPathComponent] stringByDeletingPathExtension];
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL * destinationURL = [documentsURL URLByAppendingPathComponent:epubFileName];
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"filename == %@", epubFileName]];
    if ([[NSManagedObjectContext MR_contextForCurrentThread] executeFetchRequest:fetchRequest error:nil].count) {
        return;
    }
    
    self.epubController = [[KFEpubController alloc] initWithEpubURL:epubFileURL andDestinationFolder:destinationURL];
    [self.epubController openWithCompletionBlock:^(KFEpubContentModel * contentModel){
        [BookOperations saveBookFromContentModel:contentModel epubFilename:epubFileName completionBlock:^(){
            completion();
        }];
    }];
}

@end
