//
//  NSString+EIMAddtions.h
//  Emoji IM
//
//  Created by Genji on 2015/04/30.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (EIMAdditions)

@property (nonatomic, readonly) NSString *eim_codePointString;
@property (nonatomic, readonly) BOOL eim_isUppercaseCharacter;

- (NSAttributedString *)eim_attributedString;

@end
