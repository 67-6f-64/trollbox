//
//  TickerData.m
//  trollbox
//
//  Created by Chris Rebel on 4/12/14.
//  Copyright (c) 2014 Chris Rebel. All rights reserved.
//

#import "TickerData.h"

@implementation TickerData

- (NSAttributedString *)formattedString {
    
    NSString *last = [NSString stringWithFormat:@"Last: %@     ", self.last];
    NSString *high = [NSString stringWithFormat:@"High: %@     ", self.high];
    NSString *low = [NSString stringWithFormat:@"Low: %@     ", self.low];
    NSString *avg = [NSString stringWithFormat:@"Average: %@     ", self.avg];
    NSString *vol = [NSString stringWithFormat:@"Volume: %@ / %@     ", self.vol_cur, self.vol];
    NSString *buy = [NSString stringWithFormat:@"Buy: %@     ", self.buy];
    NSString *sell = [NSString stringWithFormat:@"Sell: %@     ", self.sell];
    NSString *updated = [NSString stringWithFormat:@"Updated: %@", self.updated];
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0], NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0]};
    
    NSMutableAttributedString *formattedString = [[NSMutableAttributedString alloc] initWithString:@""];

    NSMutableAttributedString *lastF = [[NSMutableAttributedString alloc] initWithString:last];
    [lastF setAttributes:attributes range:NSMakeRange(0, 5)];
    [formattedString appendAttributedString:lastF];
    
    NSMutableAttributedString *highF = [[NSMutableAttributedString alloc] initWithString:high];
    [highF setAttributes:attributes range:NSMakeRange(0, 5)];
    [formattedString appendAttributedString:highF];

    NSMutableAttributedString *lowF = [[NSMutableAttributedString alloc] initWithString:low];
    [lowF setAttributes:attributes range:NSMakeRange(0, 4)];
    [formattedString appendAttributedString:lowF];

    NSMutableAttributedString *avgF = [[NSMutableAttributedString alloc] initWithString:avg];
    [avgF setAttributes:attributes range:NSMakeRange(0, 8)];
    [formattedString appendAttributedString:avgF];

    NSMutableAttributedString *volF = [[NSMutableAttributedString alloc] initWithString:vol];
    [volF setAttributes:attributes range:NSMakeRange(0, 7)];
    [formattedString appendAttributedString:volF];
    
    NSMutableAttributedString *buyF = [[NSMutableAttributedString alloc] initWithString:buy];
    [buyF setAttributes:attributes range:NSMakeRange(0, 4)];
    [formattedString appendAttributedString:buyF];

    NSMutableAttributedString *sellF = [[NSMutableAttributedString alloc] initWithString:sell];
    [sellF setAttributes:attributes range:NSMakeRange(0, 5)];
    [formattedString appendAttributedString:sellF];
    
    NSMutableAttributedString *updatedF = [[NSMutableAttributedString alloc] initWithString:updated];
    [updatedF setAttributes:attributes range:NSMakeRange(0, 8)];
    [formattedString appendAttributedString:updatedF];
    
    return formattedString;
}

@end
