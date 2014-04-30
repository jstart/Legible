//
//  Book.h
//  Legible
//
//  Created by Christopher Truman on 4/28/14.
//  Copyright (c) 2014 truman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * language;

@end
