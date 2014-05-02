//
//  ChatMessage.m
//  trollbox
//
//  Created by Chris Rebel on 4/12/14.
//  Copyright (c) 2014 Chris Rebel. All rights reserved.
//

#import "ChatMessage.h"
#import "GTMNSString+HTML.h"

@implementation ChatMessage

- (void)setData:(NSDictionary *)data {
    _data = data;
    
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, MAXFLOAT)];
    testLabel.numberOfLines = 0;
    testLabel.lineBreakMode = NSLineBreakByWordWrapping;
    testLabel.attributedText = self.formattedMessage;
    [testLabel sizeToFit];
    
    self.cellHeight = testLabel.frame.size.height + 20.0;
}

- (NSMutableAttributedString *)formattedMessage {
    if(!_formattedMessage) {
        NSString *login = [self.data objectForKey:@"login"];
        NSString *msg = [self.data objectForKey:@"msg"];
        
        NSRegularExpression *nameExpression = [NSRegularExpression regularExpressionWithPattern:@"u(0[a-zA-Z0-9]{3})" options:NSRegularExpressionCaseInsensitive error:nil];
        
		NSMutableString *mutableMsg = [msg mutableCopy];
		NSArray *matches = [nameExpression matchesInString:msg options:0 range:NSMakeRange(0, [msg length])];
		for (NSTextCheckingResult *match in matches) {
		    NSRange matchRange = [match range];
            NSRange firstCaptureGroupRange = [match rangeAtIndex:1];
            
		    NSString *matchString = [msg substringWithRange:matchRange];
            NSString *captureGroupString = [msg substringWithRange:firstCaptureGroupRange];
            
			NSScanner *scanner = [NSScanner scannerWithString:captureGroupString];
			uint32_t unicodeInt;
			if ([scanner scanHexInt:&unicodeInt]) {
			    unicodeInt = OSSwapHostToLittleInt32(unicodeInt); // To make it byte-order safe
			    NSString *unicodeString = [[NSString alloc] initWithBytes:&unicodeInt length:4 encoding:NSUTF32LittleEndianStringEncoding];
                mutableMsg = [[mutableMsg stringByReplacingOccurrencesOfString:matchString withString:unicodeString] mutableCopy];
			} else {
			    // Conversion failed, invalid input.
			}
		}
        
        msg = [mutableMsg gtm_stringByUnescapingFromHTML];
        
        NSString *output = [NSString stringWithFormat:@"%@: %@", login, msg];
        UIColor *userColor = [self userColor:[self.data objectForKey:@"usr_clr"]];
        
        NSDictionary *attributes = @{NSForegroundColorAttributeName: userColor, NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0]};
        _formattedMessage = [[NSMutableAttributedString alloc] initWithString:output];
        [_formattedMessage setAttributes:attributes range:NSMakeRange(0,login.length)];
    }
    
    return _formattedMessage;
}

- (UIColor *)userColor:(NSString *)hexColorString {
    unsigned long color = strtoul([hexColorString UTF8String] + 1, NULL, 16);
    return [UIColor colorWithRed:((float)((color & 0xFF0000) >> 16))/255.0 green:((float)((color & 0xFF00) >> 8))/255.0 blue:((float)(color & 0xFF))/255.0 alpha:1.0];
}

@end
