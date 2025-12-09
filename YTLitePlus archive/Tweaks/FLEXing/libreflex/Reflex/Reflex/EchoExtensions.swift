//
//  EchoExtensions.swift
//  Reflex
//
//  Created by Tanner Bennett on 4/12/21.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

import Foundation
import Echo
import CEcho
import FLEX

typealias RawType = UnsafeRawPointer
typealias Field = (name: String, type: Metadata)

enum ReflexError: Error {
    case failedDynamicCast(src: Any.Type, dest: Any.Type)
    
    var description: String {
        switch self {
            case .failedDynamicCast(let src, let dest):
                return "Dynamic cast from type '\(src)' to '\(dest)' failed"
        }
    }
}

/// For some reason, breaking it all out into separate vars like this
/// eliminated a bug where the pointers in the final set were not the
/// same pointers that would appear if you manually reflected a type
extension KnownMetadata.Builtin {
    static var supported: Set<RawType> = Set(_typePtrs)
    
    private static var _types: [Any.Type] = [
        Int8.self, Int16.self, Int32.self, Int64.self, Int.self,
        UInt8.self, UInt16.self, UInt32.self, UInt64.self, UInt.self,
        Float32.self, Float64.self, Float.self, Double.self, CGFloat.self,
    ]
    
    private static var _typePtrs: [RawType] {
        return self._types.map { ~$0 }
    }
    
    static var typeEncodings: [RawType: FLEXTypeEncoding] = [
        ~Int8.self: .char,
        ~Int16.self: .short,
        ~Int32.self: .int,
        ~Int64.self: .longLong,
        ~Int.self: .longLong,
        ~UInt8.self: .unsignedChar,
        ~UInt16.self: .unsignedShort,
        ~UInt32.self: .unsignedInt,
        ~UInt64.self: .unsignedLongLong,
        ~UInt.self: .unsignedLongLong,
        ~Float32.self: .float,
        ~Float64.self: .double,
        ~CGFloat.self: .double,
    ]
}

extension KnownMetadata {
    static let string: StructDescriptor = reflectStruct(String.self)!.descriptor
    static let array: StructDescriptor = reflectStruct([Any].self)!.descriptor
    static let dictionary: StructDescriptor = reflectStruct([String:Any].self)!.descriptor
    static let date: StructDescriptor = reflectStruct(Date.self)!.descriptor
    static let data: StructDescriptor = reflectStruct(Data.self)!.descriptor
    static let url: StructDescriptor = reflectStruct(URL.self)!.descriptor
    
    static let foundationStructs: Set<RawType> = Set([
        string, array, dictionary, date, data, url
    ].map(\.ptr))
    
    static func isFoundationStruct(_ metadata: Metadata) -> Bool {
        guard let metadata = metadata as? StructMetadata else {
            return false
        }
        
        return foundationStructs.contains(metadata.descriptor.ptr)
    }
    
    static let foundationTypeDescriptorToClass: [RawType: AnyClass] = [
        string.ptr: NSString.self,
        array.ptr: NSArray.self,
        dictionary.ptr: NSDictionary.self,
        date.ptr: NSDate.self,
        data.ptr: NSData.self,
        url.ptr: NSURL.self,
    ]
    
    static func classForStruct(_ metadata: Metadata) -> AnyClass? {
        guard let metadata = metadata as? StructMetadata else {
            return nil
        }
        
        return foundationTypeDescriptorToClass[metadata.descriptor.ptr]
    }
}

extension Metadata {
    private var `enum`: EnumMetadata { self as! EnumMetadata }
    private var `struct`: StructMetadata { self as! StructMetadata }
    private var tuple: TupleMetadata { self as! TupleMetadata }
    
    /// This doesn't actually work very well since Double etc aren't opaque,
    /// but instead contain a single member that is itself opaque
    private var isBuiltin_alt: Bool {
        return self is OpaqueMetadata
    }
    
    /// This is `true` for any "primitive" type
    var isBuiltin: Bool {
        guard self.vwt.flags.isPOD else {
            return false
        }
        
        return KnownMetadata.Builtin.supported.contains(self.ptr)
    }
    
    /// Whether this type represents a struct (or optional) besides
    /// a primitive that is bridged to Objective-C as an object 
    var isNonTriviallyBridgedToObjc: Bool {
        switch self.kind {
            case .struct:
                return KnownMetadata.isFoundationStruct(self.struct)
            case .optional:
                return self.enum.optionalType.isNonTriviallyBridgedToObjc
                
            default:
                return false
        }
    }
    
    /// Programmatically perform a cast like `foo as? T` at runtime
    func dynamicCast(from variable: Any) throws -> Any {
        func cast<T>(_: T.Type) throws -> T {
            guard let casted = variable as? T else {
                let srcType = Swift.type(of: variable)
                throw ReflexError.failedDynamicCast(src: srcType, dest: T.self)
            }
            
            return casted
        }
        
        return try _openExistential(self.type, do: cast(_:))
    }
    
    var typeEncoding: FLEXTypeEncoding {
        switch self.kind {
            case .class:
                return .objcObject
                
            case .struct:
                // Hard-code types for builtin types and a few foundation structs
                if self.isBuiltin {
                    return KnownMetadata.Builtin.typeEncodings[~self.type]!
                }
                // If it bridges to Objc and _isn't_ a primitive, treat it as an object
                if self.isNonTriviallyBridgedToObjc {
                    // TODO encode as proper type
                    return .objcObject
                }
                
                return .structBegin
                
            case .enum:
                if self.enum.descriptor.numPayloadCases > 0 {
                    return .unknown
                }
                return .unknown // TODO: return proper sized int for enums?
            
            case .optional:
                // For optionals, use the encoding of the Wrapped type
                return self.enum.optionalType!.typeEncoding
                
            case .tuple:
                return .structBegin
                
            case .foreignClass,
                 .opaque,
                 .function,
                 .existential,
                 .metatype,
                 .objcClassWrapper,
                 .existentialMetatype,
                 .heapLocalVariable,
                 .heapGenericLocalVariable,
                 .errorObject:
                return .unknown
        }
    }
    
    // TODO: enums would show up as anonymous structs I think
    var typeEncodingString: String {
        switch self.typeEncoding {
            case .objcObject:
                return FLEXTypeEncoding.encodeObjcObject(typeName: self.description)
            case .structBegin:
                switch self.kind {
                    case .tuple:
                        let fieldTypes = self.tuple.elements.map(\.metadata.typeEncodingString)
                        return FLEXTypeEncoding.encodeStruct(typeName: self.description, fields: fieldTypes)
                    case .struct:
                        let fieldTypes = self.struct.fields.map(\.type.typeEncodingString)
                        return FLEXTypeEncoding.encodeStruct(typeName: self.description, fields: fieldTypes)
                    case .optional:
                        return self.enum.optionalType!.typeEncodingString
                    default:
                        fatalError()
                }
            default:
                // For now, convert type encoding char into a string
                return String(Character(.init(UInt8(bitPattern: self.typeEncoding.rawValue))))
        }
    }
}

protocol NominalType: TypeMetadata {
    var genericMetadata: [Metadata] { get }
    var fieldOffsets: [Int] { get }
    var fields: [Field] { get }
    var description: String { get }
}

protocol ContextualNominalType: NominalType {
    associatedtype NominalTypeDescriptor: TypeContextDescriptor
    var descriptor: NominalTypeDescriptor { get }
}

extension ClassMetadata: NominalType, ContextualNominalType {
    typealias NominalTypeDescriptor = ClassDescriptor
}
extension StructMetadata: NominalType, ContextualNominalType {    
    typealias NominalTypeDescriptor = StructDescriptor
}
extension EnumMetadata: NominalType, ContextualNominalType {
    typealias NominalTypeDescriptor = EnumDescriptor
}

// MARK: KVC
extension ContextualNominalType {
    func recordIndex(forKey key: String) -> Int? {
        return self.descriptor.fields.records.firstIndex { $0.name == key }
    }
    
    func fieldOffset(for key: String) -> Int? {
        if let idx = self.recordIndex(forKey: key) {
            return self.fieldOffsets[idx]
        }
        
        return nil
    }
    
    func fieldType(for key: String) -> Metadata? {
        return self.fields.first(where: { $0.name == key })?.type
    }
    
    var shallowFields: [Field] {
        let r: [FieldRecord] = self.descriptor.fields.records
        return r.filter(\.hasMangledTypeName).map {
            return (
                $0.name,
                reflect(self.type(of: $0.mangledTypeName)!)
            )
        }
    }
}

extension StructMetadata {
    func getValue<T, O>(forKey key: String, from object: O) -> T {
        let offset = self.fieldOffset(for: key)!
        let ptr = object~
        return ptr[offset]
    }
    
    func getValueBox<O>(forKey key: String, from object: O) -> AnyExistentialContainer {
        guard let offset = self.fieldOffset(for: key), let type = self.fieldType(for: key) else {
            fatalError("Class '\(self.descriptor.name)' has no member '\(key)'")
        }

        let ptr = object~
        return .init(boxing: ptr + offset, type: type)
    }
    
    func set<T, O>(value: T, forKey key: String, on object: inout O) {
        self.set(value: value, forKey: key, pointer: object~)
    }
    
    func set(value: Any, forKey key: String, pointer ptr: RawPointer) {
        let offset = self.fieldOffset(for: key)!
        let type = self.fieldType(for: key)!
        ptr.storeBytes(of: value, type: type, offset: offset)
    }
    
    var fields: [Field] { self.shallowFields }
}

extension ClassMetadata {
    /// Does not traverse the class hierarchy
    private func objcIvar(for key: String) -> Ivar? {
        guard let idx = self.descriptor.fields.records.map(\.name)
                .firstIndex(where: { $0 == key }) else {
            return nil
        }
        
        var count: UInt32 = 0
        guard let ivars = class_copyIvarList(self.type as? AnyClass, &count) else {
            return nil
        }
        
        defer { free(ivars) }
        return ivars[idx]
    }
    
    /// Does not traverse the class hierarchy
    func ivarOffset(for key: String) -> Int? {
        // If the class has objc heritage, get the field offset using the objc
        // metadata, because Swift won't update the field offsets in the face of
        // resilient base classes
        guard self.flags.usesSwiftRefCounting else {
            guard let ivar = self.objcIvar(for: key) else {
                return nil
            }
            
            return ivar_getOffset(ivar)
        }
        
        // Does this ivar exist?
        guard let idx = self.recordIndex(forKey: key) else {
            // Not here, but maybe in a superclass
            return nil
        }
        
        // Yes! Now, grab the offset and offset it by the superclass's instance size
//        if let supercls = self.superclassMetadata?.type {
//            return self.fieldOffsets[idx] //+ class_getInstanceSize(supercls as? AnyClass)
//        }
        
        return self.fieldOffsets[idx]
    }
    
    func getValue<T, O>(forKey key: String, from object: O) -> T {
        guard let offset = self.ivarOffset(for: key) else {
            if let sup = self.superclassMetadata {
                return sup.getValue(forKey: key, from: object)
            } else {
                fatalError("Class '\(self.descriptor.name)' has no member '\(key)'")
            }
        }

        let ptr = object~
        return ptr[offset]
    }
    
    func getValueBox<O>(forKey key: String, from object: O) -> AnyExistentialContainer {
        guard let offset = self.ivarOffset(for: key), let type = self.fieldType(for: key) else {
            if let sup = self.superclassMetadata {
                return sup.getValueBox(forKey: key, from: object)
            } else {
                fatalError("Class '\(self.descriptor.name)' has no member '\(key)'")
            }
        }

        let ptr = object~
        return .init(boxing: ptr + offset, type: type)
    }
    
    func set<T, O>(value: T, forKey key: String, on object: inout O) {
        self.set(value: value, forKey: key, pointer: object~)
    }
    
    func set(value: Any, forKey key: String, pointer ptr: RawPointer) {
        guard let offset = self.ivarOffset(for: key) else {
            if let sup = self.superclassMetadata {
                return sup.set(value: value, forKey: key, pointer: ptr)
            } else {
                fatalError("Class '\(self.descriptor.name)' has no member '\(key)'")
            }
        }
        
        var value = value
        let box = container(for: value)
        
        // Check if we need to do a cast first; sometimes things like
        // Double or Int will be boxed up as NSNumber first.
        let type = self.fieldType(for: key)!
        if type.type != box.type, let cast = try? type.dynamicCast(from: value) {
            value = cast
        }
        
        ptr.storeBytes(of: value, type: type, offset: offset)
    }
    
    /// Consolidate all fields in the class hierarchy
    var fields: [Field] {
        if let sup = self.superclassMetadata, sup.isSwiftClass {
            return self.shallowFields + sup.fields
        }
        
        return self.shallowFields
    }
}

extension EnumMetadata {
    var fields: [Field] { self.shallowFields }
}

// MARK: Protocol conformance checking
extension TypeMetadata {
    func conforms(to _protocol: Any) -> Bool {
        let existential = reflect(_protocol) as! MetatypeMetadata
        let instance = existential.instanceMetadata as! ExistentialMetadata
        let desc = instance.protocols.first!
        
        return !self.conformances.filter({ $0.protocol == desc }).isEmpty
    }
}

// MARK: MetadataKind
extension MetadataKind {
    var isObject: Bool {
        return self == .class || self == .objcClassWrapper
    }
}

// MARK: Populating AnyExistentialContainer
extension AnyExistentialContainer {
    var toAny: Any {
        return unsafeBitCast(self, to: Any.self)
    }
    
    var isEmpty: Bool {
        return self.data == (0, 0, 0)
    }
    
    init(boxing valuePtr: RawPointer, type: Metadata) {
        self = .init(metadata: type)
        self.store(value: valuePtr)
    }
    
    init(nil optionalType: EnumMetadata) {
        self = .init(metadata: optionalType)
        self.zeroMemory()
    }
    
    init(nil optionalType: ClassMetadata) {
        self = .init(metadata: optionalType)
        self.zeroMemory()
    }
    
    mutating func store(value newValuePtr: RawPointer) {
        self.metadata.vwt.initializeWithCopy(self.getValueBuffer(), newValuePtr)
    }
    
    /// Calls into `projectValue()` but will allocate a box
    /// first if needed for types that are not inline
    mutating func getValueBuffer() -> RawPointer {
        // Allocate a box if needed and return it
        if !self.metadata.vwt.flags.isValueInline && self.data.0 == 0 {
            return self.metadata.allocateBoxForExistential(in: &self)~
        }
        
        // We don't need a box or already have one
        return self.projectValue()~
    }
    
    mutating func zeroMemory() {
        let size = self.metadata.vwt.size
        self.getValueBuffer().initializeMemory(
            as: Int8.self, repeating: 0, count: size
        )
    }
}

extension FieldRecord: CustomDebugStringConvertible {
    public var debugDescription: String {
        let ptr = self.mangledTypeName.assumingMemoryBound(to: UInt8.self)
        return self.name + ": \(String(cString: ptr)) ( \(self.referenceStorage) : \(self.flags))"
    }
}

extension EnumMetadata {
    fileprivate var optionalType: Metadata! { self.genericMetadata.first }
    
    func getTag(for instance: Any) -> UInt32 {
        var box = container(for: instance)
        return self.enumVwt.getEnumTag(for: box.projectValue())
    }
    
    func copyPayload(from instance: Any) -> (value: Any, type: Any.Type)? {
        let tag = self.getTag(for: instance)
        let isPayloadCase = self.descriptor.numPayloadCases > tag
        if isPayloadCase {
            let caseRecord = self.descriptor.fields.records[Int(tag)]
            let type = self.type(of: caseRecord.mangledTypeName)!
            var caseBox = container(for: instance)
            // Copies in the value and allocates a box as needed
            let payload = AnyExistentialContainer(
                boxing: caseBox.projectValue()~,
                type: reflect(type)
            )
            return (unsafeBitCast(payload, to: Any.self), type)
        }
        
        return nil
    }
}

extension ProtocolDescriptor {
    var description: String {
        return self.name
    }
}

extension FunctionMetadata {
    var typeSignature: String {
        let params = self.paramMetadata.map(\.description).joined(separator: ", ")
        return "(" + params + ") -> " + self.resultMetadata.description
    }
}

extension TupleMetadata {
    var signature: String {
        let pairs = zip(self.labels, self.elements)
        return "(" + pairs.map { "\($0): \($1.metadata.description)" }.joined(separator: ", ") + ")"
    }
}

extension NominalType {
    var genericDescription: String {
        return "\(self.type)"
//        let generics = self.genericMetadata.map(\.description).joined(separator: ", ")
//        guard !generics.isEmpty else {
//            return "\(self.type)"            
//        }
//        
//        return "\(self.type)<\(generics)>"
    }
}

extension Metadata {
    var description: String {
        switch self.kind {
            case .class, .struct, .enum:
                return "\((self as! NominalType).genericDescription)"
            case .optional:
                return "\(self.enum.optionalType!.description)?"
            case .foreignClass:
                return "~ForeignClass"
            case .opaque:
                return "~Opaque"
            case .tuple:
                return (self as! TupleMetadata).signature
            case .function:
                return (self as! FunctionMetadata).typeSignature
            case .existential:
                if self.ptr~ == Any.self~ || self.ptr~ == AnyObject.self~ {
                    return "\(self.type)"
                }
                
                let ext = (self as! ExistentialMetadata)
                let protocols = ext.protocols.map(\.description).joined(separator: " & ")
                if let supercls = ext.superclassMetadata {
                    return supercls.description + " & " + protocols
                } else {
                    return protocols
                }
            case .metatype:
                return (self as! MetatypeMetadata).instanceMetadata.description + ".self"
            case .objcClassWrapper:
                return "~ObjcClassWrapper"
            case .existentialMetatype:
                if self.ptr~ == AnyClass.self~ {
                    return "AnyClass"
                }
                return "~Existential"
            case .heapLocalVariable:
                return "~HLV"
            case .heapGenericLocalVariable:
                return "~HGLV"
            case .errorObject:
                return "~ErrorObject"
        }
    }
}
