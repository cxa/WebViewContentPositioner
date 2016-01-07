//
//  UIWebView+WebViewContentPositioner.m
//  WebViewContentPositioner
//
//  Created by CHEN Xian’an on 1/6/16.
//  Copyright © 2016 lazyapps. All rights reserved.
//

@import UIKit;
@import ObjectiveC.runtime;

static void (*origTraitCollectionDidChange)(id, SEL, UITraitCollection *);
static void newTraitCollectionDidChange(id, SEL, UITraitCollection *);

@implementation UIWebView (WebViewContentPositioner)

+ (void)load
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Method origMethod = class_getInstanceMethod(self, @selector(traitCollectionDidChange:));
    origTraitCollectionDidChange = (void *)method_getImplementation(origMethod);
    if (!class_addMethod(self, @selector(traitCollectionDidChange:), (IMP)newTraitCollectionDidChange, method_getTypeEncoding(origMethod)))
      method_setImplementation(origMethod, (IMP)newTraitCollectionDidChange);
  });
}

@end

void newTraitCollectionDidChange(id self, SEL cmd, UITraitCollection *tc) {
  origTraitCollectionDidChange(self, cmd, tc);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
  [self performSelector:NSSelectorFromString(@"WebViewContentPositioner_traitCollectionDidChange:") withObject:tc];
#pragma clang diagnostic pop
}