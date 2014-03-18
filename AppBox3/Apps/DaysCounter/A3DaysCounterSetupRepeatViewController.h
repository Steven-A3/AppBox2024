//
//  A3DaysCounterSetupRepeatViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3KeyboardProtocol.h"

@interface A3DaysCounterSetupRepeatViewController : UITableViewController<A3KeyboardDelegate,UITextFieldDelegate>{

}

@property (strong, nonatomic) NSMutableDictionary *eventModel;
@end
