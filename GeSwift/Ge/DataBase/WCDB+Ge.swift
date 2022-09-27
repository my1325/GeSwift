//
//  WCDB+Ge.swift
//  Tool
//
//  Created by my on 2018/9/21.
//  Copyright © 2018 my. All rights reserved.
//

import Foundation
import WCDBSwift

public final class TableFilter<T: WCDBSwift.TableCodable> {
    
    public init(_ type: T.Type) {}
    
    public private(set) var whereCondition: Condition?
    
    public private(set) var orderBy: [OrderBy]?
    
    public private(set) var groupBy: [GroupBy]?
    
    public private(set) var having: Having?
    
    public private(set) var limit: Limit?
    
    public private(set) var offset: Offset?
    
    @discardableResult
    public func `where`(_ whereSequence: ((T.CodingKeys.Type) -> Condition)?) -> TableFilter<T>  {
        self.whereCondition = whereSequence?(T.CodingKeys.self)
        return self
    }
    
    @discardableResult
    public func groupBy(_ groupBySequence: ((T.CodingKeys.Type) -> [GroupBy])?) -> TableFilter<T> {
        self.groupBy = groupBySequence?(T.CodingKeys.self)
        return self
    }
    
    @discardableResult
    public func orderBy(_ orderBySequence: ((T.CodingKeys.Type) -> [OrderBy])?) -> TableFilter<T> {
        self.orderBy = orderBySequence?(T.CodingKeys.self)
        return self
    }
    
    @discardableResult
    public func having(_ havingSequence: ((T.CodingKeys.Type) -> Having)?) -> TableFilter<T> {
        self.having = havingSequence?(T.CodingKeys.self)
        return self
    }
    
    @discardableResult
    public func limit(_ limitSequence: ((T.CodingKeys.Type) -> Limit)?) -> TableFilter<T> {
        self.limit = limitSequence?(T.CodingKeys.self)
        return self
    }
    
    @discardableResult
    public func offset(_ offsetSequence: ((T.CodingKeys.Type) -> Offset)?) -> TableFilter<T> {
        self.offset = offsetSequence?(T.CodingKeys.self)
        return self
    }
}

public protocol TableProtocol: TableCodable {

    static var tableName: String { get }
    
    static func getObjects(in database: Database, on columns: [Self.CodingKeys], using filter: ((TableFilter<Self>) -> Void)?) throws -> [Self]
    
    static func update(object: Self, in database: Database, on columns: [Self.CodingKeys], using filter: ((TableFilter<Self>) -> Void)?) throws -> UInt64
    
    static func update(values: [ColumnEncodable], in database: Database, on columns: [Self.CodingKeys], using filter: ((TableFilter<Self>) -> Void)?) throws -> UInt64
    
    static func insert(objects: [Self], in database: Database, on columns: [Self.CodingKeys]) throws

    static func delete(from database: Database, using filter: ((TableFilter<Self>) -> Void)?) throws -> UInt64

    static func migrateToDatabase(_ database: Database) throws
    
    static func count(in database: Database, using filter: ((TableFilter<Self>) -> Void)?) throws -> UInt64
}

extension TableProtocol {
    
    public static func getObjects(in database: Database, on columns: [Self.CodingKeys] = [], using filter: ((TableFilter<Self>) -> Void)? = nil) throws -> [Self] {
        
        var properties: [PropertyConvertible] = columns
        if columns.count == 0 { properties = Self.Properties.all }
        
        let select = try database.prepareSelect(on: properties, fromTable: self.tableName)
        
        let fil: TableFilter<Self> = TableFilter(self)
        filter?(fil)

        if let condition = fil.whereCondition { select.where(condition) }
        if let groupby = fil.groupBy { select.group(by: groupby) }
        if let having = fil.having { select.having(having) }
        if let orderby = fil.orderBy { select.order(by: orderby) }
        if let limit = fil.limit {
            if let offset = fil.offset { select.limit(limit, offset: offset) }
            else { select.limit(limit) }
        }
        
        return try select.allObjects()
    }
    
    public static func update(object: Self, in database: Database, on columns: [Self.CodingKeys] = [], using filter: ((TableFilter<Self>) -> Void)? = nil) throws -> UInt64 {
        
        var properties: [PropertyConvertible] = columns
        if columns.count == 0 { properties = Self.Properties.all }

        let fil: TableFilter<Self> = TableFilter(self)
        filter?(fil)

        let update = try database.prepareUpdate(table: tableName, on: properties)
        if let condition = fil.whereCondition { update.where(condition) }
        if let orderby = fil.orderBy { update.order(by: orderby) }
        if let limit = fil.limit {
            if let offset = fil.offset { update.limit(limit, offset: offset) }
            else { update.limit(limit) }
        }
        
        try update.execute(with: object)
        return UInt64(update.changes ?? 0)
    }
    
    public static func update(values: [ColumnEncodable], in database: Database, on columns: [Self.CodingKeys] = [], using filter: ((TableFilter<Self>) -> Void)? = nil) throws -> UInt64 {
        
        var properties: [PropertyConvertible] = columns
        if columns.count == 0 { properties = Self.Properties.all }
        
        let fil: TableFilter<Self> = TableFilter(self)
        filter?(fil)
        let update = try database.prepareUpdate(table: tableName, on: properties)
        if let condition = fil.whereCondition { update.where(condition) }
        if let orderby = fil.orderBy { update.order(by: orderby) }
        if let limit = fil.limit {
            if let offset = fil.offset { update.limit(limit, offset: offset) }
            else { update.limit(limit) }
        }
        
        try update.execute(with: values)
        return UInt64(update.changes ?? 0)
    }
    
    public static func insert(objects: [Self], in database: Database, on columns: [Self.CodingKeys] = []) throws {
        
        var properties: [PropertyConvertible] = columns
        if columns.count == 0 { properties = Self.Properties.all }

        let insert = try database.prepareInsert(on: properties, intoTable: self.tableName)
        try insert.execute(with: objects)
    }
    
    public static func delete(from database: Database, using filter: ((TableFilter<Self>) -> Void)? = nil) throws -> UInt64 {
        
        let fil: TableFilter<Self> = TableFilter(self)
        filter?(fil)

        let delete = try database.prepareDelete(fromTable: self.tableName)

        if let condition = fil.whereCondition { delete.where(condition) }
        if let orderby = fil.orderBy { delete.order(by: orderby) }
        if let limit = fil.limit {
            if let offset = fil.offset { delete.limit(limit, offset: offset) }
            else { delete.limit(limit) }
        }
        
        try delete.execute()
        return UInt64(delete.changes ?? 0)
    }
    
    public static func migrateToDatabase(_ database: Database) throws {
        try database.create(table: tableName, of: Self.self)
    }
    
    public static func count(in database: Database, using filter: ((TableFilter<Self>) -> Void)? = nil) throws -> UInt64 {

        let fil: TableFilter<Self> = TableFilter(self)
        filter?(fil)

        let select = StatementSelect().select(Self.Properties.any.count()).from(self.tableName)
        
        if let condition = fil.whereCondition { select.where(condition) }
        if let groupby = fil.groupBy { select.group(by: groupby) }
        if let having = fil.having { select.having(having) }
        if let orderby = fil.orderBy { select.order(by: orderby) }
        if let limit = fil.limit {
            if let offset = fil.offset { select.limit(limit, offset: offset) }
            else { select.limit(limit) }
        }
        
        let finalSelect = try database.prepare(select)
        if try finalSelect.step() {
            return finalSelect.value(atIndex: 0) ?? 0
        }
        return 0
    }
}

extension Array where Element: WCDBSwift.TableCodable {
    
    public func insert(in database: Database, into table: String, on columns: [Element.CodingKeys] = []) throws {
        
        var properties: [PropertyConvertible] = columns
        if columns.count == 0 { properties = Element.Properties.all }
        
        let insert = try database.prepareInsert(on: properties, intoTable: table)
        try insert.execute(with: self)
    }
}
