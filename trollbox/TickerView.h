//
//  TickerView.h
//  trollbox
//
//  Created by Chris Rebel on 4/12/14.
//  Copyright (c) 2014 Chris Rebel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TickerData.h"

@interface TickerView : UIView

@property (nonatomic, assign) BOOL continueAnimation;
@property (nonatomic, weak) IBOutlet UILabel *tickerLabel;

- (void)lookupDataForLocale:(NSString *)locale;

@end
