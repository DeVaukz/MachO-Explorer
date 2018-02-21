//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       MachODocument.swift
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

class MachODocument: NSDocument
{
    @objc var rootNode: MKNode!
    
    // UI State //
    @objc dynamic var addressMode: MKNodeAddressType = .contextAddress
    @objc dynamic var searchString: String? = nil
    @objc dynamic var selection: Model? = nil
}


extension MachODocument
{
    override func read(from url: URL, ofType typeName: String) throws {
        let memoryMap = try MKMemoryMap.init(contentsOfFile: url)
        
        // Try initializing a dyld shared cache
        do {
            self.rootNode = try MKSharedCache(flags: .fromSourceFile, atAddress: 0, inMapping: memoryMap)
            return
        } catch let error as NSError {
            // If MK_EINVAL is returned, the file is not a shared cache.
            if mk_error_t(rawValue: UInt32(error.code)) != MK_EINVAL {
                throw error
            }
        }
            
        // Try initializing a FAT binary
        do {
            self.rootNode = try MKFatBinary(memoryMap: memoryMap)
            return
        } catch let error as NSError {
            // If MK_EINVAL is returned, the file is not a FAT binary.
            if mk_error_t(rawValue: UInt32(error.code)) != MK_EINVAL {
                throw error
            }
        }
        
        // Try initializing a Mach-O
        self.rootNode = try MKMachOImage(name: nil, flags: MKMachOImageFlags(rawValue: 0), atAddress: 0, inMapping: memoryMap)
    }
}


extension MachODocument
{
    override func makeWindowControllers() {
        let windowController = MachODocumentWindowController(windowNibName: NSNib.Name("MachoDocumentWindow"))
        self.addWindowController(windowController)
    }
}
