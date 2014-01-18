//
//  ToDoList_AddToDoItemViewController.h
//  ToDoList
//
//  Created by Anthony Oliveri on 12/23/13.
//  Copyright (c) 2013 Anthony Oliveri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDLAppDelegate.h"


/* 
    Here, the user to either enter a name for a new list or
    enter a name for a new item of an existing list.
*/

@interface TDLAddObjectViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *textField;

-(IBAction)textFieldReturn:(id)sender;

@end
