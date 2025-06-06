//
//  AsyncStreamed.swift
//  Runnieri
//
//  Created by Youssef Ghattas on 06/06/2025.
//

@propertyWrapper
struct AsyncStreamed<Value> {
    private var (stream, continuation) = AsyncStream<Value>.makeStream()
    
    var wrappedValue: Value {
        didSet {
            continuation.yield(wrappedValue)
        }
    }
    
    var projectedValue: AsyncStream<Value> { stream }
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}
