//
//  TDLToDoItem.h
//  ToDoList
//
//  Created by Anthony Oliveri on 12/25/13.
//  Copyright (c) 2013 Anthony Oliveri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDLToDoItem : NSObject

@property NSString *itemName;
@property bool completed;
@property (readonly) NSDate *creationDate;

@end
