//
//  NSString+Calculate.h
//  Utilities
//
//  Created by Hirohisa Kawasaki on 13/06/10.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Calculate)
- (CGSize)sizeForWidth:(CGFloat)width font:(UIFont *)font;
- (NSUInteger)numberOfComposedCharacterSequences;
- (NSString *)substringComposedCharacterSequencesToIndex:(NSUInteger)to;
@end
