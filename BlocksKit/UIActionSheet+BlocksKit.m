//
//  UIActionSheet+BlocksKit.m
//  BlocksKit
//

#import "UIActionSheet+BlocksKit.h"
#import "A2BlockDelegate+BlocksKit.h"

#pragma mark Custom delegate

@interface A2DynamicUIActionSheetDelegate : A2DynamicDelegate

@end

@implementation A2DynamicUIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	id realDelegate = self.realDelegate;
	if ([realDelegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)])
		[realDelegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
	
	if (buttonIndex == actionSheet.cancelButtonIndex)
		return;
	
	id key = [NSNumber numberWithInteger:buttonIndex];
	BKBlock block = [self.handlers objectForKey:key];
	if (block)
		block();
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
	id realDelegate = self.realDelegate;
	if ([realDelegate respondsToSelector:@selector(willPresentActionSheet:)])
		return [realDelegate willPresentActionSheet:actionSheet];

	void (^block)(UIActionSheet *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(actionSheet);
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
	id realDelegate = self.realDelegate;
	if ([realDelegate respondsToSelector:@selector(didPresentActionSheet:)])
		return [realDelegate didPresentActionSheet:actionSheet];
	
	void (^block)(UIActionSheet *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(actionSheet);
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
	id realDelegate = self.realDelegate;
	if ([realDelegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)])
		[realDelegate actionSheet:actionSheet willDismissWithButtonIndex:buttonIndex];
	
	void (^block)(UIActionSheet *, NSInteger) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(actionSheet, buttonIndex);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	id realDelegate = self.realDelegate;
	if ([realDelegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)])
		[realDelegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];

	
	void (^block)(UIActionSheet *, NSInteger) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(actionSheet, buttonIndex);
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
	id realDelegate = self.realDelegate;
	if ([realDelegate respondsToSelector:@selector(actionSheetCancel:)])
		return [realDelegate actionSheetCancel:actionSheet];
	
	id key = [NSNumber numberWithInteger:actionSheet.cancelButtonIndex];
	BKBlock block = [self.handlers objectForKey:key];
	if (block)
		block();
}

@end

#pragma mark - Category

@implementation UIActionSheet (BlocksKit)

+ (void)load {
	@autoreleasepool {
		[self registerDynamicDelegate];
		NSDictionary *methods = [NSDictionary dictionaryWithObjectsAndKeys:nil,
								 @"willShowBlock", @"willPresentActionSheet:",
								 @"didShowBlock", @"didPresentActionSheet:",
								 @"willDismissBock", @"actionSheet:willDismissWithButtonIndex:",
								 @"didDismissBlock", @"actionSheet:didDismissWithButtonIndex:",
								 nil];
		[self linkDelegateMethods:methods];
	}
}

#pragma mark Initializers

+ (id)sheetWithTitle:(NSString *)title {
	return BK_AUTORELEASE([[UIActionSheet alloc] initWithTitle:title]);
}

- (id)initWithTitle:(NSString *)title {
	return [self initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
}

#pragma mark Actions

- (NSInteger)addButtonWithTitle:(NSString *)title handler:(BKBlock)block {
#warning TODO - copy-paste the dynamic delegate setter here
	NSAssert(title.length, @"A button without a title cannot be added to an action sheet.");
	NSInteger index = [self addButtonWithTitle:title];

	id key = [NSNumber numberWithInteger:index];

	if (block)
		[[self.dynamicDelegate handlers] setObject:block forKey:key];
	else
		[[self.dynamicDelegate handlers] removeObjectForKey:key];

	return index;
}

- (NSInteger)setDestructiveButtonWithTitle:(NSString *)title handler:(BKBlock)block {
	NSInteger index = [self addButtonWithTitle:title handler:block];
	self.destructiveButtonIndex = index;
	return index;
}
											
- (NSInteger)setCancelButtonWithTitle:(NSString *)title handler:(BKBlock)block {
	NSInteger cancelButtonIndex = -1;

	if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && !title)
		title = NSLocalizedString(@"Cancel", nil);

	if (title)
		cancelButtonIndex = [self addButtonWithTitle:title];

	self.cancelButtonIndex = cancelButtonIndex;
	[self setCancelBlock:block];
	return cancelButtonIndex;
}

#pragma mark Properties

- (BKBlock)handlerForButtonAtIndex:(NSInteger)index {
	id key = [NSNumber numberWithInteger:index];
	return [[self.dynamicDelegate handlers] objectForKey:key];
}

- (BKBlock)cancelBlock {
	return [self handlerForButtonAtIndex:self.cancelButtonIndex];
}

- (void)setCancelBlock:(BKBlock)block {
#warning TODO - copy-paste the dynamic delegate setter here

	if (self.cancelButtonIndex == -1) {
		[self setCancelButtonWithTitle:nil handler:block];
	} else {
		id key = [NSNumber numberWithInteger:self.cancelButtonIndex];
		
		if (block)
			[[self.dynamicDelegate handlers] setObject:block forKey:key];
		else
			[[self.dynamicDelegate handlers] removeObjectForKey:key];
	}
}

@end