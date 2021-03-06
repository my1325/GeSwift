//
//  DataSourceDriver+Map.swift
//  GeSwift
//
//  Created by my on 2021/1/12.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation

extension DataSourceDriver {
    public func map<T>(_ transfomer: @escaping (Value) -> T) -> DataSourceDriver<T> {
        return DataSourceMapDriver(source: self, transformer: transfomer)
    }
    
    public func reduce<A, E>(_ initialSeed: A, reducer: @escaping (A, E) -> A) -> DataSourceDriver<A> where Value == [E] {
        return DataSourceReduceDriver(source: self, initialSeed: initialSeed, reducer: reducer)
    }
    
    public func combineLatest<T>(_ other: DataSourceDriver<T>) -> DataSourceDriver<(Value, T)> {
        return DataSourceCombineLatestDriver(source1: self, source2: other)
    }
    
    public func merge(_ other: DataSourceDriver<Value>) -> DataSourceDriver<[Value]> {
        return DataSourceMergeDriver(sources: [self, other])
    }
    
    public static func merge(_ drivers: [DataSourceDriver<Value>]) -> DataSourceDriver<[Value]> {
        return DataSourceMergeDriver(sources: drivers)
    }
}

class DataSourceMapDriver<Source, Value>: DataSourceDriver<Value> {
    
    init(source: DataSourceDriver<Source>, transformer: @escaping (Source) -> Value) {
        super.init(initialValue: transformer(source.value))
        source.drive {
            self.accept(transformer($0))
        }
    }
}

class DataSourceCombineLatestDriver<Source1, Source2>: DataSourceDriver<(Source1, Source2)> {
    
    var latestValue1: Source1
    var latestValue2: Source2
    init(source1: DataSourceDriver<Source1>, source2: DataSourceDriver<Source2>) {
        self.latestValue1 = source1.value
        self.latestValue2 = source2.value
        super.init(initialValue: (source1.value, source2.value))
        
        source1.drive { value1 in
            self.latestValue1 = value1
            self.accept((value1, self.latestValue2))
        }
        
        source2.drive { value2 in
            self.latestValue2 = value2
            self.accept((self.latestValue1, value2))
        }
    }
}

class DataSourceMergeDriver<Value>: DataSourceDriver<[Value]> {
    
    var values: [Value]
    init(sources: [DataSourceDriver<Value>]) {
        values = sources.map({ $0.value })
        super.init(initialValue: values)
        
        for index in 0 ..< sources.count {
            let driver = sources[index]
            driver.drive { value in
                self.values[index] = value
                self.accept(self.values)
            }
        }
    }
}

class DataSourceReduceDriver<Source, Value>: DataSourceDriver<Value> {
    
    init(source: DataSourceDriver<[Source]>, initialSeed: Value, reducer: @escaping (Value, Source) -> Value) {
        super.init(initialValue: initialSeed)
        source.drive { sourceValues in
            let value = sourceValues.reduce(initialSeed, reducer)
            self.accept(value)
        }
    }
}
