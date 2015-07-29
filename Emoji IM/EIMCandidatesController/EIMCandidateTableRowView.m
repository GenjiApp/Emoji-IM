//
//  EIMCandidateTableRowView.m
//  Emoji IM
//
//  Created by Genji on 2015/05/09.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import "EIMCandidateTableRowView.h"

@implementation EIMCandidateTableRowView

- (void)drawSelectionInRect:(NSRect)dirtyRect
{
  [super drawSelectionInRect:dirtyRect];
  [[NSColor selectedTextBackgroundColor] set];
  NSRectFill(dirtyRect);
}

- (NSBackgroundStyle)interiorBackgroundStyle
{
  return NSBackgroundStyleLight;
}

@end
