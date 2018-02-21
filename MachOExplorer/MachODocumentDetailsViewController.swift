//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       MachODocumentDetailsViewController.swift
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

class MachODocumentDetailsViewController: NSTabViewController
{
    let detailViewControllers: [MachODetailViewController] = [
        MachODetailsViewController(),
        MachOHexDetailViewController()
    ]
    
    override var representedObject: Any? {
        didSet {
            for viewController in self.detailViewControllers {
                viewController.representedObject = self.representedObject
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.commonInit()
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.transitionOptions = TransitionOptions()
        self.tabStyle = .unspecified
        
        for viewController in self.detailViewControllers {
            viewController.addObserver(self, forKeyPath: "wantsDisplay", options: .initial, context: nil)
        }
    }
    
    deinit {
        for viewController in self.detailViewControllers {
            viewController.removeObserver(self, forKeyPath: "wantsDisplay", context: nil)
        }
    }
}


extension MachODocumentDetailsViewController
{
    override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)
        
        if self.tabViewItems.indices.contains(self.selectedTabViewItemIndex),
           let outgoingViewController = self.tabViewItems[self.selectedTabViewItemIndex].viewController as? MachODetailViewController
        {
            outgoingViewController.willDisappear()
        }
        
        if let tabViewItem = tabViewItem,
           let incomingViewController = tabViewItem.viewController as? MachODetailViewController
        {
            incomingViewController.willAppear()
        }
    }
}


extension MachODocumentDetailsViewController
{
    @objc func updateVisibleViewControllers() {
        let newValue = self.detailViewControllers.filter({ viewController -> Bool in
            return viewController.wantsDisplay
        }).map({ viewController -> NSTabViewItem in
            return viewController.tabViewItem
        })
        
        self.tabViewItems = newValue;
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "wantsDisplay"
        {
            type(of: self).cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateVisibleViewControllers), object: nil)
            self.perform(#selector(updateVisibleViewControllers), with: nil, afterDelay: 0)
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
