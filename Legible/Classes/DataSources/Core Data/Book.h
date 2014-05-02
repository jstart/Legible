//
//  Book.h
//  Legible
//
//  Created by Christopher Truman on 5/1/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSString * epubContentBaseURL;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * lastChapter;
@property (nonatomic, retain) NSNumber * lastPage;

@end
