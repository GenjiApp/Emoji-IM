//
//  EIMInputController.m
//  Emoji IM
//
//  Created by Genji on 2015/01/27.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import "EIMInputController.h"
#import "EIMAppDelegate.h"
#import "NSString+EIMAddtions.h"


@interface EIMInputController ()

@property (nonatomic, strong) NSMutableString *originalBuffer;
@property (nonatomic, copy) NSString *composedBuffer;
@property (nonatomic) NSInteger insertionIndex;

- (IBAction)showPreferencesWindow:(id)sender;
- (IBAction)orderFrontStandardAboutPanel:(id)sender;
- (IBAction)openManualPage:(id)sender;

@end


@implementation EIMInputController

#pragma mark -
#pragma mark IMKInputController Methods
- (id)initWithServer:(IMKServer *)server delegate:(id)delegate client:(id)inputClient
{
  self = [super initWithServer:server delegate:delegate client:inputClient];
  if(self) {
#ifdef DEBUG
    NSLog(@"%@, %@, %@", NSStringFromSelector(_cmd), inputClient, delegate);
#endif
    self.originalBuffer = [[NSMutableString alloc] init];
    self.insertionIndex = 0;
  }
  return self;
}

- (NSMenu *)menu
{
  EIMAppDelegate *appDelegate = [NSApplication sharedApplication].delegate;
  return appDelegate.menu;
}


#pragma mark -
#pragma mark IMKServerInput Methods
- (BOOL)inputText:(NSString *)string client:(id)sender
{
  self.composedBuffer = nil;

  EIMAppDelegate *appDelegate = [NSApp delegate];
  if(appDelegate.keyCode == kVK_JIS_Eisu) {
    return YES;
  }

  if([appDelegate.excludedApps containsObject:[sender bundleIdentifier]]) {
    return NO;
  }

  BOOL isUppercaseCharacter = string.eim_isUppercaseCharacter;
  if(!self.originalBuffer.length && !isUppercaseCharacter) {
    return NO;
  }

  BOOL isCapsLockModeEnabled = appDelegate.capsLockModeEnabled;
  NSEventModifierFlags modifierFlags = [NSEvent modifierFlags];
  BOOL isCapsLockPressed = ((modifierFlags & NSAlphaShiftKeyMask) == NSAlphaShiftKeyMask);
  BOOL isHandledCharacter = [string isEqualToString:string.uppercaseString];
  if((isCapsLockModeEnabled && !isCapsLockPressed) ||
     (!isCapsLockModeEnabled && !isHandledCharacter)) {
    [EIMCandidatesController closeCandidatesPanel];
    if(self.originalBuffer.length) {
      [self commitComposition:sender];
    }
    return NO;
  }

  [self.originalBuffer insertString:string atIndex:self.insertionIndex];
  self.insertionIndex++;

  // setMarkedText:selectionRange:replacementRange: には、 NSAttributedString を与えないと
  // 挿入点キャレットが描画されない。
  [sender setMarkedText:[self.originalBuffer eim_attributedString] selectionRange:NSMakeRange(self.insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];

  [EIMCandidatesController updateCandidatesWithString:self.originalBuffer forClient:sender fromInputController:self];

  return YES;
}

- (BOOL)didCommandBySelector:(SEL)selector client:(id)sender
{
  if(!self.originalBuffer.length) {
    return NO;
  }

  if([self respondsToSelector:selector]) {
    [self performSelector:selector withObject:sender afterDelay:0];
  }
  else {
#ifdef DEBUG
    NSLog(@"unknown key binding: %@", NSStringFromSelector(selector));
#endif
  }

  return YES;
}

- (void)commitComposition:(id)sender
{
  [EIMCandidatesController closeCandidatesPanel];

  NSString *string = nil;
  if(self.composedBuffer.length) {
    if([NSEvent modifierFlags] & NSAlternateKeyMask) {
      string = self.composedBuffer.eim_codePointString;
    }
    else {
      string = self.composedBuffer;
    }
  }
  else {
    string = self.originalBuffer;
  }

  [sender insertText:string replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
  self.insertionIndex = 0;
  [self.originalBuffer setString:@""];
  self.composedBuffer = nil;
}


#pragma mark -
#pragma mark IMKStateSetting Methods
- (void)activateServer:(id)sender
{
  [super activateServer:sender];
  if(self.originalBuffer.length) {
    [EIMCandidatesController updateCandidatesWithString:self.originalBuffer forClient:sender fromInputController:self];
  }
}

- (void)deactivateServer:(id)sender
{
  [super deactivateServer:sender];
  if([EIMCandidatesController isPanelVisible]) {
    [EIMCandidatesController closeCandidatesPanel];
  }
}


#pragma mark -
#pragma mark Action Method
- (IBAction)showPreferencesWindow:(id)sender
{
  EIMAppDelegate *appDelegate = [NSApp delegate];
  [appDelegate.preferencesWindowController.window orderFrontRegardless];
  [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)orderFrontStandardAboutPanel:(id)sender
{
  [NSApp orderFrontStandardAboutPanel:nil];
  [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)openManualPage:(id)sender
{
  NSURL *aURL = [NSURL URLWithString:NSLocalizedString(@"http://genjiapp.com/mac/emoji-im/manual_en.html", nil)];
  [[NSWorkspace sharedWorkspace] openURL:aURL];
}


#pragma mark -
#pragma mark EIMCandidatesViewDelegate
- (void)candidatesViewSelectionChanged:(NSString *)candidateString
{
  self.composedBuffer = candidateString;

  EIMAppDelegate *appDelegate = [NSApp delegate];
  if(appDelegate.showsCompositeString) {
    // ここではあえて NSAttributedString ではなく NSString を渡す。
    // NSAttributedString を渡すと、その後の確定文字入力のフォントが乱れて？ 数字が全角幅になってしまう。
    [self.client setMarkedText:self.composedBuffer selectionRange:NSMakeRange(self.composedBuffer.length, 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
  }
}

- (void)candidatesViewSelected:(NSString *)candidateString
{
  [self commitComposition:[self client]];
}


#pragma mark -
#pragma mark Text Command Methods
- (void)insertNewline:(id)sender
{
  [self commitComposition:sender];
}

- (void)insertNewlineIgnoringFieldEditor:(id)sender
{
  [self commitComposition:sender];
}

- (void)insertTab:(id)sender
{
  if([EIMCandidatesController isPanelVisible]) {
    if([NSEvent modifierFlags] & NSShiftKeyMask) {
      [EIMCandidatesController selectPreviousCandidate];
    }
    else {
      [EIMCandidatesController selectNextCandidate];
    }
  }
}

- (void)cancelOperation:(id)sender
{
  self.composedBuffer = nil;
  [sender setMarkedText:[self.originalBuffer eim_attributedString] selectionRange:NSMakeRange(self.originalBuffer.length, 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
  self.insertionIndex = self.originalBuffer.length;

  if([EIMCandidatesController isPanelVisible]) {
    [EIMCandidatesController closeCandidatesPanel];
  }
  else {
    [self commitComposition:sender];
  }
}

- (void)deleteBackward:(id)sender
{
  if(self.insertionIndex > 0 && self.insertionIndex <= self.originalBuffer.length) {
    self.insertionIndex--;
    [self.originalBuffer deleteCharactersInRange:NSMakeRange(self.insertionIndex, 1)];

    [sender setMarkedText:[self.originalBuffer eim_attributedString] selectionRange:NSMakeRange(self.insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];

    [EIMCandidatesController updateCandidatesWithString:self.originalBuffer forClient:sender fromInputController:self];
  }
}

- (void)deleteForward:(id)sender
{
  if(self.insertionIndex < self.originalBuffer.length) {
    [self.originalBuffer deleteCharactersInRange:NSMakeRange(self.insertionIndex, 1)];

    [sender setMarkedText:[self.originalBuffer eim_attributedString] selectionRange:NSMakeRange(self.insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];

    [EIMCandidatesController updateCandidatesWithString:self.originalBuffer forClient:sender fromInputController:self];
  }
}

- (void)deleteToEndOfParagraph:(id)sender
{
  [self.originalBuffer setString:[self.originalBuffer substringToIndex:self.insertionIndex]];
  self.insertionIndex = self.originalBuffer.length;
  [sender setMarkedText:[self.originalBuffer eim_attributedString] selectionRange:NSMakeRange(self.insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];

  [EIMCandidatesController updateCandidatesWithString:self.originalBuffer forClient:sender fromInputController:self];
}

- (void)moveUp:(id)sender
{
  if([EIMCandidatesController isPanelVisible]) {
    [EIMCandidatesController selectPreviousCandidate];
  }
}

- (void)moveDown:(id)sender
{
  if([EIMCandidatesController isPanelVisible]) {
    [EIMCandidatesController selectNextCandidate];
  }
}

- (void)moveLeft:(id)sender
{
  if(self.insertionIndex > 0) {
    self.insertionIndex--;
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.originalBuffer];
    [sender setMarkedText:attrString selectionRange:NSMakeRange(self.insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
  }
}

- (void)moveRight:(id)sender
{
  if(self.insertionIndex < self.originalBuffer.length) {
    self.insertionIndex++;
    [sender setMarkedText:[self.originalBuffer eim_attributedString] selectionRange:NSMakeRange(self.insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
  }
}

- (void)moveBackward:(id)sender
{
  [self moveLeft:sender];
}

- (void)moveForward:(id)sender
{
  [self moveRight:sender];
}

- (void)moveToBeginningOfParagraph:(id)sender
{
  self.insertionIndex = 0;
  [sender setMarkedText:[self.originalBuffer eim_attributedString] selectionRange:NSMakeRange(self.insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
}

- (void)moveToEndOfParagraph:(id)sender
{
  self.insertionIndex = self.originalBuffer.length;
  [sender setMarkedText:[self.originalBuffer eim_attributedString] selectionRange:NSMakeRange(self.insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
}

- (void)transpose:(id)sender
{
  if(self.insertionIndex == 0) {
    return;
  }
  else if(self.insertionIndex == self.originalBuffer.length) {
    self.insertionIndex--;
  }
  NSString *characterAtRightOfInsertionIndex = [self.originalBuffer substringWithRange:NSMakeRange(self.insertionIndex, 1)];
  [self.originalBuffer deleteCharactersInRange:NSMakeRange(self.insertionIndex, 1)];
  [self.originalBuffer insertString:characterAtRightOfInsertionIndex atIndex:self.insertionIndex - 1];
  self.insertionIndex++;
  [sender setMarkedText:[self.originalBuffer eim_attributedString] selectionRange:NSMakeRange(self.insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];

  [EIMCandidatesController updateCandidatesWithString:self.originalBuffer forClient:sender fromInputController:self];
}

@end
