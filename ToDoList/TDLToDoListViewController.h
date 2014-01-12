//
//  TDLToDoListViewController.h
//  ToDoList
//
//  Created by Anthony Oliveri on 12/23/13.
//  Copyright (c) 2013 Anthony Oliveri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDLAppDelegate.h"

@interface TDLToDoListViewController : UITableViewController

@property NSMutableArray *toDoItems;    // tableView items
@property NSArray *toDoItemObjects;     // managed objects from persistent store
@property NSArray *toDoLists;     // managed

@end
