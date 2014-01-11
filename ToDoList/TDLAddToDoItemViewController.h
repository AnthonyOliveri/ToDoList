//
//  ToDoList_AddToDoItemViewController.h
//  ToDoList
//
//  Created by Anthony Oliveri on 12/23/13.
//  Copyright (c) 2013 Anthony Oliveri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDLToDoItem.h"
#import "TDLAppDelegate.h"
#import "TDLToDoListViewController.h"

@interface TDLAddToDoItemViewController : UIViewController

@property TDLToDoItem *toDoItem;    // New item to add to the list
@property (weak, nonatomic) IBOutlet UITextField *textField;

-(IBAction)textFieldReturn:(id)sender;

@end
