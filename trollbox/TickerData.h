//
//  TickerData.h
//  trollbox
//
//  Created by Chris Rebel on 4/12/14.
//  Copyright (c) 2014 Chris Rebel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TickerData : NSObject

@property (nonatomic, copy) NSString *high;
@property (nonatomic, copy) NSString *low;
@property (nonatomic, copy) NSString *avg;
@property (nonatomic, copy) NSString *vol;
@property (nonatomic, copy) NSString *vol_cur;
@property (nonatomic, copy) NSString *last;
@property (nonatomic, copy) NSString *buy;
@property (nonatomic, copy) NSString *sell;
@property (nonatomic, copy) NSString *updated;
@property (nonatomic, copy) NSString *server_time;

- (NSAttributedString *)formattedString;

@end
