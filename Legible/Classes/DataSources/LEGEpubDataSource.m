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
    [self.epubController openWithCompletionBlock:^(KFEpubContentModel * contentModel, NSURL * epubBaseURL){
        [self replaceAllCSSFilesAtPath:epubBaseURL];
        
        [BookOperations saveBookFromContentModel:contentModel epubFileName:epubFileName epubContentBaseURL:[epubBaseURL absoluteString] completionBlock:^(){
            completion();
        }];
    }];
}

-(void) replaceAllCSSFilesAtPath:(NSURL *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:path
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error){
                                                            NSLog(@"[Error] %@ (%@)", error, url);
                                                            return YES;
                                                        }];
    
    NSMutableArray *mutableFileURLs = [NSMutableArray array];
    
    NSURL * cssURL = [[NSBundle mainBundle] URLForResource:@"userStyle" withExtension:@"css"];
    for (NSURL *fileURL in enumerator) {
        NSString *filename;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        
        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        // Skip directories with '_' prefix, for example
        if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
            [enumerator skipDescendants];
            continue;
        }
        
        if (![isDirectory boolValue]) {
            [mutableFileURLs addObject:fileURL];
        }
        if ([filename hasSuffix:@".css"]) {
            NSError * error = nil;
            [fileManager removeItemAtURL:fileURL error:&error];
            if (error) {
                NSLog(@"%@", error);
            }
            [fileManager copyItemAtURL:cssURL toURL:fileURL error:&error];
            if (error) {
                NSLog(@"%@", error);
            }
        }
    }
}

@end
