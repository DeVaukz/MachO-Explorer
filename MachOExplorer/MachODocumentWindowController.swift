//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       MachODocumentWindowController.swift
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2018 D.V. All rights reserved.
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

import Cocoa

class MachODocumentWindowController: NSWindowController
{
    @IBOutlet var addressModeSelector: NSSegmentedControl!
    @IBOutlet var displayModeSelectorItem: NSToolbarItem!
    @IBOutlet var displayModeSelector: NSSegmentedControl!
    @IBOutlet var searchField: NSSearchField!
    @IBOutlet var panelVisibilitySelector: NSSegmentedControl!
    
    var previousDetailSelection: String? = nil
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let splitViewController = MachODocumentWindowContentViewController()
        
        // Load the outline view controller (master)
        let outlineController = MachODocumentOutlineViewController(nibName: NSNib.Name("MachODocumentOutlineViewController"), bundle: nil)
        outlineController.representedObject = self.document
        let _ = outlineController.view // Force nib load
        
        // Load the detail view controller
        let detailController = MachODocumentDetailsViewController()
        detailController.representedObject = self.document
        detailController.addObserver(self, forKeyPath: "tabViewItems", options: [.initial, .new], context: nil)
        self.displayModeSelector.bind(NSBindingName("selectedIndex"), to: detailController, withKeyPath: "selectedTabViewItemIndex", options: nil)
        
        let masterSplitViewItem = NSSplitViewItem(viewController: outlineController)
        masterSplitViewItem.minimumThickness = 250
        splitViewController.addSplitViewItem(masterSplitViewItem)
        
        let detailSplitViewItem = NSSplitViewItem(viewController: detailController)
        detailSplitViewItem.minimumThickness = 600
        splitViewController.addSplitViewItem(detailSplitViewItem)
        
        self.contentViewController = splitViewController
    }
}


extension MachODocumentWindowController
{
    @IBAction func displayModeChanged(_ sender: NSSegmentedControl?) {
        if let sender = sender, sender.selectedSegment >= 0 {
            self.previousDetailSelection = sender.label(forSegment: sender.selectedSegment)
        } else {
            self.previousDetailSelection = nil
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "tabViewItems"
        {
            let tabViewController = (object as! NSTabViewController)
            let newValue: [NSTabViewItem] = tabViewController.tabViewItems
            
            if newValue.count == 0 {
                self.displayModeSelector.isHidden = true
            } else {
                self.displayModeSelector.isHidden = false
            }
            
            self.displayModeSelector.segmentCount = newValue.count
            
            var i = 0
            for tab in newValue {
                self.displayModeSelector.setLabel(tab.label, forSegment: i)
                self.displayModeSelector.setWidth(0, forSegment: i)
                i = i + 1
            }
            
            if let previousSelection = self.previousDetailSelection {
                for i in 0..<self.displayModeSelector.segmentCount {
                    if self.displayModeSelector.label(forSegment: i) == previousSelection {
                        self.displayModeSelector.selectedSegment = i
                        tabViewController.selectedTabViewItemIndex = i
                    }
                }
            } else if self.displayModeSelector.segmentCount > 0 {
                self.displayModeSelector.selectedSegment = 0
                tabViewController.selectedTabViewItemIndex = 0
            }
            
            self.displayModeSelector.layoutSubtreeIfNeeded()
            self.displayModeSelector.sizeToFit()
            self.displayModeSelectorItem.maxSize = NSSize(width: self.displayModeSelector.frame.size.width, height: self.displayModeSelectorItem.maxSize.height)
            self.displayModeSelectorItem.minSize = NSSize(width: 50, height: self.displayModeSelectorItem.minSize.height)
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
