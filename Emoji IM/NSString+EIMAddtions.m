//
//  NSString+EIMAddtions.m
//  Emoji IM
//
//  Created by Genji on 2015/04/30.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import "NSString+EIMAddtions.h"

@implementation NSString (EIMAdditions)

- (NSString *)eim_codePointString
{
  NSMutableString *result = [NSMutableString string];
  for(NSUInteger index = 0; index < self.length; index++) {
    unichar code = [self characterAtIndex:index];
    [result appendFormat:@"\\U%04x", code];
  }

  return result.uppercaseString;
}

- (BOOL)eim_isUppercaseCharacter
{
  static NSCharacterSet *invertedOfUppercaseCharacterSet = nil;
  if(!invertedOfUppercaseCharacterSet) {
    invertedOfUppercaseCharacterSet = [NSMutableCharacterSet uppercaseLetterCharacterSet].invertedSet;
  }

  return ([self rangeOfCharacterFromSet:invertedOfUppercaseCharacterSet].location == NSNotFound);
}

- (NSAttributedString *)eim_attributedString
{
  return [[NSAttributedString alloc] initWithString:self];
}

@end
