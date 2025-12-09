//
//  Extensions.swift
//  ReflexTests
//
//  Created by Tanner Bennett on 4/12/21.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

import Foundation
import Echo

typealias RawPointer = UnsafeMutableRawPointer

extension UnsafeRawPointer {
    subscript<T>(offset: Int) -> T {
        get {
            return self.load(fromByteOffset: offset, as: T.self)
        }
    }
}

extension RawPointer {
    /// Generic subscript. Do not use when T = Any unless you mean it...
    subscript<T>(offset: Int) -> T {
        get {
            return self.load(fromByteOffset: offset, as: T.self)
        }
        
        set {
            self.storeBytes(of: newValue, toByteOffset: offset, as: T.self)
        }
    }

    /// Allocates space for a structure (or enum?) without an initial value
    static func allocateBuffer(for type: Metadata) -> Self {
        return RawPointer.allocate(
            byteCount: type.vwt.size,
            alignment: type.vwt.flags.alignment
        )
    }
    
    /// Allocates space for and stores a value.
    /// You should probably use AnyExistentialContainer instead.
    init(wrapping value: Any, withType metadata: Metadata) {
        self = RawPointer.allocateBuffer(for: metadata)
        self.storeBytes(of: value, type: metadata)
    }
    
    /// For storing a value from an Any container
    func storeBytes(of value: Any, type: Metadata, offset: Int = 0) {
        var box = container(for: value)
        type.vwt.initializeWithCopy((self + offset), box.projectValue()~)
//        (self + offset).copyMemory(from: box.projectValue(), byteCount: type.vwt.size)
    }
    
    /// For copying a tuple element instance from a pointer
    func copyMemory(ofTupleElement valuePtr: UnsafeRawPointer, layout e: TupleMetadata.Element) {
        e.metadata.vwt.initializeWithCopy((self + e.offset), valuePtr~)
//        (self + e.offset).copyMemory(from: valuePtr, byteCount: e.metadata.vwt.size)
    }
    
    /// For copying a type instance from a pointer
    func copyMemory(from pointer: RawPointer, type: Metadata, offset: Int = 0) {
        type.vwt.initializeWithCopy((self + offset), pointer)
//        (self + offset).copyMemory(from: pointer, byteCount: type.vwt.size)
    }
}

extension Unmanaged where Instance == AnyObject {
    /// Quickly retain an object before you write its address to memory or something
    @discardableResult
    static func retainIfObject(_ thing: Any) -> Bool {
        if container(for: thing).metadata.kind.isObject {
            _ = self.passRetained(thing as AnyObject).retain()
            return true
        }
        
        return false
    }
}

postfix operator ~
postfix func ~<T>(target: T) -> RawPointer {
    return unsafeBitCast(target, to: RawPointer.self)
}
prefix func ~<T,U>(target: T) -> U {
    return unsafeBitCast(target, to: U.self)
}
