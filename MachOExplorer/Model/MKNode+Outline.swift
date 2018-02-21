//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       MKNode+Outline.swift
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

extension MKNode /* OutlineModel */
{
}

extension MKNode /* OutlineNodeModel */
{
    override var outline_isLeaf: Bool {
        return self.outline_children.count == 0
    }
    
    override var outline_childCount: Int {
        return self.outline_children.count
    }
    
    override var outline_children: [OutlineNodeModel] {
        if let cachedChildren = objc_getAssociatedObject(self, "outlineChildren") as? [OutlineNodeModel] {
            return cachedChildren
        }
        
        var children = Array<OutlineNodeModel>()
        
        let nodeLayout = self.layout
        let nodeFields = nodeLayout.allFields
        
        for field in nodeFields {
            if let fieldAdapter = self.adapter(forField: field) {
                children += fieldAdapter.outline_nodes
            }
        }
        
        objc_setAssociatedObject(self, "outlineChildren", children, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return children
    }
    
    override var outline_title: String {
    #if TRACE_DESCRIPTIONS_AND_VALUES
        return "[N]" + self.description
    #else
        return self.description
    #endif
    }
}
