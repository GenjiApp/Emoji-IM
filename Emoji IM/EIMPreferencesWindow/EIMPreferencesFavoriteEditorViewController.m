//
//  EIMPreferencesFavoriteEditorViewController.m
//  Emoji IM
//
//  Created by Genji on 2015/05/11.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import "EIMPreferencesFavoriteEditorViewController.h"
#import "EIMPreferencesKeys.h"

@interface EIMPreferencesFavoriteEditorViewController () <NSTextFieldDelegate>

@property (nonatomic, weak) IBOutlet NSTextField *replaceTextField;
@property (nonatomic, weak) IBOutlet NSTextField *withTextField;
@property (nonatomic, weak) IBOutlet NSButton *okButton;

- (IBAction)favoriteEdited:(id)sender;

@end

@implementation EIMPreferencesFavoriteEditorViewController

- (void)dealloc
{
  self.delegate = nil;
}

- (void)viewWillAppear
{
  [super viewWillAppear];

  switch(self.editorMode) {
    case EIMFavoriteEditorModeAdd:
      self.replaceTextField.stringValue = @"";
      self.withTextField.stringValue = @"";
      break;
    case EIMFavoriteEditorModeEdit:
      self.replaceTextField.stringValue = self.editingFavoriteDictionary[EIMDictionaryNameKey];
      self.withTextField.stringValue = self.editingFavoriteDictionary[EIMDictionaryEmojiKey];
      break;
  }
}


#pragma mark -
#pragma mark Action Method
- (IBAction)favoriteEdited:(id)sender
{
  if([self.delegate respondsToSelector:@selector(favoriteEditorView:didEndEdit:)]) {
    NSString *replaceString = self.replaceTextField.stringValue;
    NSString *withString = self.withTextField.stringValue;
    if(replaceString.length && withString.length) {
      NSDictionary *favoriteDictionary = @{EIMDictionaryNameKey: replaceString,
                                           EIMDictionaryEmojiKey: withString};
      [self.delegate favoriteEditorView:self didEndEdit:favoriteDictionary];
    }
  }
  [self dismissViewController:self];
}

- (void)controlTextDidChange:(NSNotification *)obj
{
  self.okButton.enabled = (self.replaceTextField.stringValue.length && self.withTextField.stringValue.length);
}


@end
