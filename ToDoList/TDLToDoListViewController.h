//
//  TDLToDoListViewController.h
//  ToDoList
//
//  Created by Anthony Oliveri on 12/23/13.
//  Copyright (c) 2013 Anthony Oliveri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDLAppDelegate.h"


/*
    Controller for any to-do list. Here, the user can add, deleted,
    check, uncheck, or reorder items in their list.
*/

@interface TDLToDoListViewController : UITableViewController

@property NSArray *toDoItems;     // managed objects from persistent store
@property NSArray *toDoLists;

@end
