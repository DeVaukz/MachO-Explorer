//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       MachODetailViewController.swift
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
import MachOKit

class MachODetailViewController: NSViewController
{
    @objc dynamic var wantsDisplay: Bool = false
    lazy var tabViewItem: NSTabViewItem = NSTabViewItem(viewController: self)
    
    // Model //
    @objc var model: Model? = nil
    fileprivate var modelBinding: ModelBinding?
    
    // UI //
    @objc var addressMode: MKNodeAddressType = .contextAddress
    fileprivate var addressModeBinding: AddressModeBinding?
    
    override var representedObject: Any? {
        willSet {
            self.unbind(MachODetailViewController.ModelBinding.Name)
            self.unbind(MachODetailViewController.AddressModeBinding.Name)
        }
        didSet {
            guard let representedObject = self.representedObject else { return }
            self.bind(MachODetailViewController.ModelBinding.Name, to: representedObject, withKeyPath: "selection", options: nil)
            self.bind(MachODetailViewController.AddressModeBinding.Name, to: representedObject, withKeyPath: "addressMode", options: nil)
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
        return
    }
    
    deinit {
        self.unbind(ModelBinding.Name)
        self.unbind(AddressModeBinding.Name)
    }
}


extension MachODetailViewController
{
    @objc var tabViewToolTip: String { return NSStringFromClass(type(of: self)) }
    
    @objc func willAppear() {
        return
    }
    
    @objc func willDisappear() {
        return
    }
}


extension MachODetailViewController /* NSKeyValueBindingCreation */
{
    struct ModelBinding {
        static let Name = NSBindingName("model")
        let observedObject: NSObject
        let observedKeyPath: String
    }
    
    struct AddressModeBinding {
        static let Name = NSBindingName("addressMode")
        let observedObject: NSObject
        let observedKeyPath: String
    }
    
    override static func heySwiftSomePeopleStillNeedToOverrideInitialize() /* +initialize */ {
        exposeBinding(ModelBinding.Name)
        exposeBinding(AddressModeBinding.Name)
    }
    
    override func bind(_ binding: NSBindingName, to observable: Any, withKeyPath keyPath: String, options: [NSBindingOption : Any]? = nil) {
        if binding == ModelBinding.Name {
            guard let observable = observable as? NSObject else { return }
            self.unbind(binding)
            self.modelBinding = ModelBinding(observedObject: observable, observedKeyPath: keyPath)
            observable.addObserver(self, forKeyPath: keyPath, options: .initial, context: nil)
            
        } else if binding == AddressModeBinding.Name {
            guard let observable = observable as? NSObject else { return }
            self.unbind(binding)
            self.addressModeBinding = AddressModeBinding(observedObject: observable, observedKeyPath: keyPath)
            observable.addObserver(self, forKeyPath: keyPath, options: .initial, context: nil)
            
        } else {
            super.bind(binding, to: observable, withKeyPath: keyPath, options: options)
        }
    }
    
    override func unbind(_ binding: NSBindingName) {
        if binding == ModelBinding.Name {
            guard let binding = self.modelBinding else { return }
            binding.observedObject.removeObserver(self, forKeyPath: binding.observedKeyPath, context: nil)
            self.modelBinding = nil
            self.model = nil
            
        } else if binding == AddressModeBinding.Name {
            guard let binding = self.addressModeBinding else { return }
            binding.observedObject.removeObserver(self, forKeyPath: binding.observedKeyPath, context: nil)
            self.addressModeBinding = nil
            self.addressMode = .contextAddress
            
        } else {
            super.unbind(binding)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let object = object as? NSObject {
            
            if let binding = self.modelBinding, binding.observedObject == object && binding.observedKeyPath == keyPath {
                self.model = object.value(forKeyPath: binding.observedKeyPath) as! Model?
                return
                
            } else if let binding = self.addressModeBinding, binding.observedObject == object && binding.observedKeyPath == keyPath {
                self.addressMode = MKNodeAddressType(rawValue: (object.value(forKeyPath: binding.observedKeyPath) as! NSNumber).uintValue)!
                return
            }
            
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
}
