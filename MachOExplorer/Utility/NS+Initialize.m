//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//|             NS+Initialize.m
//|
//|             D.V.
//|             Copyright (c) 2018 D.V. All rights reserved.
//|
//| Permission is hereby granted, free of charge, to any person obtaining a
//| copy of this software and associated documentation files (the "Software"),
//| to deal in the Software without restriction, including without limitation
//| the rights to use, copy, modify, merge, publish, distribute, sublicense,
//| and/or sell copies of the Software, and to permit persons to whom the
//| Software is furnished to do so, subject to the following conditions:
//|
//| The above copyright notice and this permission notice shall be included
//| in all copies or substantial portions of the Software.
//|
//| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//| OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------------//

#import "NS+Initialize.h"
#import <objc/runtime.h>

@implementation NSViewController (Initialize)

static void (*NSViewController_OriginalInitialize)(id, SEL) = NULL;

static void NSViewController_Initialize(Class self, SEL _cmd)
{
    if (NSViewController_OriginalInitialize)
        NSViewController_OriginalInitialize(self, _cmd);
    
    [self heySwiftSomePeopleStillNeedToOverrideInitialize];
}

+ (void)load
{
    NSViewController_OriginalInitialize = (typeof(NSViewController_OriginalInitialize))class_replaceMethod(object_getClass(NSViewController.class), @selector(initialize), (IMP)&NSViewController_Initialize, "v16@0:8");
}

+ (void)heySwiftSomePeopleStillNeedToOverrideInitialize
{
    /* For subclasses */
}

@end
