//
//  ToDoList_AddToDoItemViewController.h
//  ToDoList
//
//  Created by Anthony Oliveri on 12/23/13.
//  Copyright (c) 2013 Anthony Oliveri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDLToDoItem.h"

@interface TDLAddToDoItemViewController : UIViewController

@property TDLToDoItem *toDoItem;

-(IBAction)saveNewItem:(id)sender;

@end
