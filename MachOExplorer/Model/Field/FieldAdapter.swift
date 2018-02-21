//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       FieldAdapter.swift
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

class FieldAdapter: NSObject
{
    let node: MKNode
    let field: MKNodeField
    
    var type: MKNodeFieldType? {
        return self.field.type
    }
    
    var value: NSObject! {
        let value = self.field.valueRecipe.value(for: self.field, of: self.node)
        return value.value as! NSObject?
    }
    
    var fieldIndex: UInt {
        let layout = self.node.layout
        var i: UInt = 0
        for field in layout.allFields {
            if field.name == self.field.name {
                break
            } else {
                i += 1
            }
        }
        return i
    }
    
    init(field: MKNodeField, ofNode node: MKNode) {
        self.node = node
        self.field = field
    }
}

extension FieldAdapter /* OutlineModel */
{
    override var outline_nodes: [OutlineNodeModel] {
        guard let value = self.value else { return [] }
        guard self.field.options.contains(.displayAsChild) else { return [] }
        
        if field.options.contains(.mergeContainerContents) {
            if let collectionType = self.type as? MKNodeFieldCollectionType {
                if let elementType = collectionType.elementType {
                    return value.outline_nodes.reduce([], { $0 + TypeAdapter(for: $1 as! NSObject, ofType: elementType).outline_nodes })
                } else {
                    return value.outline_nodes
                }
            }
            else if let _ = self.type as? MKNodeFieldNodeType {
                return value.outline_nodes
            }
        }
        
        if value is MKNode {
            return value.outline_nodes
        } else {
            return [self]
        }
    }
}

extension FieldAdapter /* DetailModel */
{
    override var detail_rows: [DetailRowModel] {
        guard let _ = self.value else { return [] }
        
        if field.options.contains(.displayAsDetail) || field.options.contains(.displayAsChild) == false
        {
            if field.options.contains(.mergeContainerContents) {
                if let collectionType = field.type as? MKNodeFieldCollectionType {
                    if let elementType = collectionType.elementType {
                        return value.detail_rows.reduce([], { $0 + TypeAdapter(for: $1 as! NSObject, ofType: elementType).detail_rows })
                    } else {
                        return value.detail_rows
                    }
                }
                else if let _ = field.type as? MKNodeFieldNodeType {
                    return value.detail_rows
                }
            }
            
            return [self]
        }
        else if field.options.contains(.displayContainerContentsAsDetail)
        {
            if let collectionType = field.type as? MKNodeFieldCollectionType {
                if let elementType = collectionType.elementType {
                    return value.detail_rows.reduce([], { $0 + TypeAdapter(for: $1 as! NSObject, ofType: elementType).detail_rows })
                } else {
                    return value.detail_rows
                }
            }
            else if let _ = field.type as? MKNodeFieldNodeType {
                return value.detail_rows
            }
        }
        
        return []
    }
}

extension FieldAdapter /* OutlineNodeModel */
{
    override var outline_isLeaf: Bool {
        return self.outline_childCount == 0
    }
    
    override var outline_childCount: Int {
        return self.outline_children.count
    }
    
    override var outline_children: [OutlineNodeModel] {
        if self.field.options.contains(.displayContainerContentsAsChild)
        {
            if let collectionType = field.type as? MKNodeFieldCollectionType {
                if let elementType = collectionType.elementType {
                    return value.outline_nodes.reduce([], { $0 + TypeAdapter(for: $1 as! NSObject, ofType: elementType).outline_nodes })
                } else {
                    return value.outline_nodes
                }
            }
        }
        
        return self.value.outline_children
    }
    
    override var outline_title: String {
        if let description = self.field.description {
        #if TRACE_DESCRIPTIONS_AND_VALUES
            return "[F]" + description
        #else
            return description
        #endif
        } else {
        #if TRACE_DESCRIPTIONS_AND_VALUES
            return "[F]" + self.field.name
        #else
            return self.field.name
        #endif
        }
    }
}

extension FieldAdapter /* DetailRowModel */
{
    override var detail_value: String? {
        if let formatter = self.field.valueFormatter,
           let formattedDescription = formatter.string(for: self.value) {
        #if TRACE_DESCRIPTIONS_AND_VALUES
            return "[F]" + formattedDescription
        #else
            return formattedDescription
        #endif
        } else {
        #if TRACE_DESCRIPTIONS_AND_VALUES
            return "[F]" + self.value.detail_value!
        #else
            return self.value.detail_value
        #endif
        }
    }
    
    override var detail_description: String? {
        if let fieldDescription = self.field.description {
        #if TRACE_DESCRIPTIONS_AND_VALUES
            return "[F]" + fieldDescription
        #else
            return fieldDescription
        #endif
        } else {
        #if TRACE_DESCRIPTIONS_AND_VALUES
            return "[F]" + self.field.name
        #else
            return self.field.name
        #endif
        }
    }
    
    override var detail_data: Data? {
        if let dataRecipe = self.field.dataRecipe,
           let node = self.node as? MKBackedNode {
            return dataRecipe.data(for: self.field, of: node)
        } else {
            return self.value.detail_data
        }
    }
    
    override func detail_address(mode addressMode: MKNodeAddressType) -> NSNumber? {
        if let dataRecipe = self.field.dataRecipe,
           let node = self.node as? MKBackedNode {
            var addr: NSNumber?
            
            ExceptionSafePerform {
                addr = dataRecipe.address(addressMode.rawValue, of: self.field, of: node)
            }
            
            return addr
        }
        else if let node = self.node as? MKAddressedNode, self.fieldIndex == 0 {
            return node.nodeAddress(addressMode) as NSNumber
        }
        else {
            return self.value.detail_address(mode: addressMode)
        }
    }
}

extension FieldAdapter: DetailRowDisplayModel
{
    var detail_group_identifier: UInt {
        return self.node.detail_group_identifier
    }
    
    var detail_backgroundColor: NSColor? {
        return nil
    }
}

extension FieldAdapter: DataModel
{
    func address(mode addressMode: MKNodeAddressType) -> NSNumber? {
        if let dataRecipe = self.field.dataRecipe,
           let node = self.node as? MKBackedNode {
            return dataRecipe.address(addressMode.rawValue, of: self.field, of: node)
        } else {
            return nil
        }
    }
    
    var data: Data? {
        if let dataRecipe = self.field.dataRecipe,
           let node = self.node as? MKBackedNode {
            return dataRecipe.data(for: self.field, of: node)
        } else {
            return nil
        }
    }
}
