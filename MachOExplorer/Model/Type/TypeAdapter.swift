//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       TypeAdapter.swift
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

class TypeAdapter: NSObject
{
    let value: NSObject
    let type: MKNodeFieldType
    let node: MKNode
    
    required init(value: NSObject, ofType type: MKNodeFieldType, inNode node: MKNode) {
        self.value = value
        self.type = type
        self.node = node;
    }
    
    static func For(value: NSObject, ofType type: MKNodeFieldType, inNode node: MKNode) -> TypeAdapter {
        if type is MKNodeFieldOptionSetType {
            return OptionSetTypeAdapter(value: value, ofType: type, inNode: node)
        }
        else if type is MKNodeFieldBitfieldType {
            return BitfieldTypeAdapter(value: value, ofType: type, inNode: node)
        }
        else if type is MKNodeFieldCollectionType {
            return CollectionTypeAdapter(value: value, ofType: type, inNode: node)
        }
        else if type is MKNodeFieldContainerType {
            return ContainerTypeAdapter(value: value, ofType: type, inNode: node)
        }
        else {
            return TypeAdapter(value: value, ofType: type, inNode: node)
        }
    }
    
    var providesSubFields: Bool { return false }
}

extension TypeAdapter /* OutlineModel */
{
    override var outline_nodes: [OutlineNodeModel] {
        return [self]
    }
}

extension TypeAdapter /* OutlineNodeModel */
{
    override var outline_isLeaf: Bool {
        return self.value.outline_isLeaf
    }
    
    override var outline_childCount: Int {
        return self.value.outline_childCount
    }
    
    override var outline_children: [OutlineNodeModel] {
        return self.value.outline_children
    }
    
    override var outline_title: String {
        if let formatter = self.type.formatter,
           let formattedDescription = formatter.string(for: self.value) {
            return formattedDescription
        } else {
            return self.value.outline_title
        }
    }
}

extension TypeAdapter /* DetailModel */
{
    override var detail_rows: [DetailRowModel] {
        return [self]
    }
}

extension TypeAdapter /* DetailRowModel */
{
    override var detail_value: String? {
        if let formatter = self.type.formatter,
           let formattedDescription = formatter.string(for: self.value) {
            return formattedDescription
        } else if let valueDescription = self.value.detail_value {
            return valueDescription
        } else {
            return nil
        }
    }
    
    override var detail_description: String? {
        return self.type.name
    }
    
    override var detail_data: Data? {
        return self.value.detail_data
    }
    
    override func detail_address(mode addressMode: MKNodeAddressType) -> NSNumber? {
        return self.value.detail_address(mode: addressMode)
    }
}
