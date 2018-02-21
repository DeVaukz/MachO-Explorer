//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       NSObject+Model.swift
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

import MachOKit

extension NSObject: Model { }

extension NSObject: OutlineModel
{
    var outline_nodes: [OutlineNodeModel] {
        return [self]
    }
}

extension NSObject: OutlineNodeModel
{
    var outline_isLeaf: Bool {
        return true
    }
    
    var outline_childCount: Int {
        return 0
    }
    
    var outline_children: [OutlineNodeModel] {
        return []
    }
    
    var outline_title: String {
        return self.description
    }
}

extension NSObject: DetailModel
{
    var detail_rows: [DetailRowModel] {
        return [self]
    }
}

extension NSObject: DetailRowModel
{
    var detail_value: String? {
        return self.description
    }
    
    var detail_description: String? {
        return type(of: self).description()
    }
    
    var detail_data: Data? {
        return nil
    }
    
    func detail_address(mode addressMode: MKNodeAddressType) -> NSNumber? {
        return nil
    }
}
