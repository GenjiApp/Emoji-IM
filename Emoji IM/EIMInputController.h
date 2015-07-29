//
//  EIMInputController.h
//  Emoji IM
//
//  Created by Genji on 2015/01/27.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import <InputMethodKit/InputMethodKit.h>
#import "EIMCandidatesController.h"

@interface EIMInputController : IMKInputController <EIMCandidatesViewDelegate>

@end
