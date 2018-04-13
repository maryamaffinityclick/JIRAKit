//
//  JIRAEntities.swift
//  Pods
//
//  Created by Will Powell on 30/08/2017.
//
//

import Foundation


protocol DisplayClass: NSObjectProtocol {
    var label:String?{get}
    func applyData(data: [AnyHashable:Any])
}

protocol ChildrenClass {
    var children:[Any]?{get}
}

enum JIRASchemaType: String {
    case project = "project"
    case issuetype = "issuetype"
    
    case string = "string"
    case priority = "priority"
    case user = "user"
    case array = "array"
    case number = "number"
}

enum JIRAOperations: String {
    case set = "set"
    case add = "add"
    case remove = "remove"
}

enum JIRASchemaSystem: String {
    case labels = "labels"
    case summary = "summary"
    case description = "description"
    case attachment = "attachment"

    case assignee = "assignee"
    case fixVersions = "fixVersions"
    case issuelinks = "issuelinks"
    case priority = "priority"
    case environment = "environment"
}

public class JIRAEntity: NSObject {
    required public override init() {
        super.init()
    }
    
    func export()->Any? {
        return [String:Any]()
    }
}

public class JIRATicket {
    
    required public init() { }
    
    public var project: JIRAProject!
    public var issueType: JIRAIssueType!
    public var lables: [String]?
    public var summary: String?
    public var ticketDescription: String?
    public var attachments: [Any]?
    
    public func export() -> [String: Any] {
        var data = [String: Any]()
        data[JIRASchemaType.project.rawValue] = self.project.export()
        data[JIRASchemaType.issuetype.rawValue] = self.issueType.export()
        data[JIRASchemaSystem.labels.rawValue] = self.lables
        data[JIRASchemaSystem.summary.rawValue] = self.summary
        data[JIRASchemaSystem.description.rawValue] = self.ticketDescription
        return data
    }
    
}

public class JIRASchema {
    var type: JIRASchemaType?
    var system: JIRASchemaSystem?
    var custom: String?
    var customId: Int?
    var items: String?
    func applyData(data: [AnyHashable:Any]) {
        if let typeStr = data["type"] as? String  {
            if let type = JIRASchemaType(rawValue:typeStr) {
                self.type = type
            }
        }
        if let systemStr = data["system"] as? String {
            if let system = JIRASchemaSystem(rawValue:systemStr) {
                self.system = system
            }
        }
        if let customId = data["customId"] as? Int {
            self.customId = customId
        }
        if let custom = data["custom"] as? String {
            self.custom = custom
        }
        if let items = data["items"] as? String {
            self.items = items
        }
    }
}

public class JIRAAllowedValue: JIRAEntity, DisplayClass {
    public var id: String?
    public var name: String?
    var value: String?
    func applyData(data: [AnyHashable:Any]) {
        if let id = data["id"] as? String {
            self.id = id
        }
        if let name = data["name"] as? String {
            self.name = name
        }
        if let value = data["value"] as? String {
            self.value = value
        }
    }
    
    var label: String? {
        get{
            if let name = name {
                return name
            }
            if let value = value {
                return value
            }
            return nil
        }
    }
    
    
    override func export() -> Any? {
        return ["id":id ?? "","name":name ?? "","value":value ?? ""]
    }
}


class JIRAJQLValue: JIRAEntity, DisplayClass{
    var displayName: String?
    var value: String?
    func applyData(data: [AnyHashable:Any]) {
        if let displayName = data["displayName"] as? String {
            self.displayName = displayName
        }
        if let value = data["value"] as? String {
            self.value = value
        }
    }
    
    var label: String? {
        get{
            if let displayName = displayName {
                return displayName
            }
            if let value = value {
                return value
            }
            return nil
        }
    }
    
    
    override func export() -> Any? {
        return ["displayName":displayName ?? "","value":value ?? ""]
    }
}


public class JIRALabel: JIRAEntity, DisplayClass {
    public var labelVal: String?
    var html: String?
    
    required public init() {
        super.init()
    }
    
    func applyData(data: [AnyHashable: Any]) {
        if let label = data["label"] as? String {
            self.labelVal = label
        }
        if let html = data["html"] as? String {
            self.html = html
        }
    }
    
    var label: String? {
        get{
            return labelVal
        }
    }
    
    override func export()->Any?{
        return self.label
    }
}


class JIRAUser: JIRAEntity, DisplayClass {
    var displayName: String?
    var key: String?
    var emailAddress: String?
    var active: Bool?
    var timeZone: String?
    var locale: String?
    var name: String?
    func applyData(data: [AnyHashable: Any]) {
        if let displayName = data["displayName"] as? String {
            self.displayName = displayName
        }
        if let key = data["key"] as? String {
            self.key = key
        }
        if let emailAddress = data["emailAddress"] as? String {
            self.emailAddress = emailAddress
        }
        if let active = data["active"] as? Bool {
            self.active = active
        }
        if let timeZone = data["timeZone"] as? String {
            self.timeZone = timeZone
        }
        if let locale = data["locale"] as? String {
            self.locale = locale
        }
        if let name = data["name"] as? String {
            self.name = name
        }
    }
    
    var label: String? {
        get{
            return displayName
        }
    }
    
    override func export() -> Any? {
        return [
            "key":key ?? "",
            "name":name ?? ""
        ]
    }
}

class JIRAField {
    var required: Bool = false
    var schema: JIRASchema?
    var identifier: String?
    var name: String?
    var autoCompleteUrl: String?
    var hasDefaultValue: Bool = false
    var operations: [JIRAOperations]?
    var allowedValues: [JIRAAllowedValue]?
    var raw: [AnyHashable:Any]?
    
    func applyData(data: [AnyHashable: Any]) {
        self.raw = data
        if let required = data["required"] as? Bool {
            self.required = required
        }
        if let schemaData = data["schema"] as? [AnyHashable: Any] {
            let schema = JIRASchema()
            schema.applyData(data: schemaData)
            self.schema = schema
        }
        if let name = data["name"] as? String {
            self.name = name
        }
        if let operations = data["operations"] as? [String] {
            let ops = operations.flatMap({ (operation) -> JIRAOperations? in
                return JIRAOperations(rawValue:operation)
            })
            self.operations = ops
        }
        
        
        if let autoCompleteUrl = data["autoCompleteUrl"] as? String {
            self.autoCompleteUrl = autoCompleteUrl
        }
        
        if let hasDefaultValue = data["hasDefaultValue"] as? Bool {
            self.hasDefaultValue = hasDefaultValue
        }
        if let allowedValues = data["allowedValues"] as? [[AnyHashable: Any]] {
            var allowedValuesOutput = [JIRAAllowedValue]()
            allowedValues.forEach({ (allowedValueData) in
                let allowedValue = JIRAAllowedValue()
                allowedValue.applyData(data: allowedValueData)
                allowedValuesOutput.append(allowedValue)
            })
            self.allowedValues = allowedValuesOutput
        }
    }
}

public class JIRAIssueType: JIRAEntity {
    var id:String?
    var desc:String?
    var iconUrl:String?
    open var name:String?
    var subtask:Bool = false
    var fields:[JIRAField]?
    
    func applyData(data:[AnyHashable: Any]) {
        if let id = data["id"] as? String {
            self.id = id
        }
        if let desc = data["description"] as? String {
            self.desc = desc
        }
        if let iconUrl = data["iconUrl"] as? String {
            self.iconUrl = iconUrl
        }
        if let name = data["name"] as? String {
            self.name = name
        }
        var fields = [JIRAField]()
        if let jiraFields = data["fields"] as? [AnyHashable: Any] {
            jiraFields.forEach({ (key,value) in
                if let v = value as? [AnyHashable:Any], let identifier = key as? String {
                    let field = JIRAField()
                    field.identifier = identifier
                    field.applyData(data: v)
                    fields.append(field)
                }
            })
        }
        self.fields = fields
    }
    
    override func export() -> Any? {
        return ["id":id ?? "","name":name ?? ""]
    }
}

public class JIRAProject:JIRAEntity {
    public var id: String?
    public var key: String?
    public var name: String?
    var avatarUrls: [String: String]?
    open var issueTypes: [JIRAIssueType]?
    func applyData(data:[AnyHashable: Any]) {
        if let id = data["id"] as? String {
            self.id = id
        }
        if let key = data["key"] as? String {
            self.key = key
        }
        if let name = data["name"] as? String {
            self.name = name
        }
        if let issueTypes = data["issuetypes"] as? [[AnyHashable: Any]] {
            var issueTypesOutput = [JIRAIssueType]()
            issueTypes.forEach({ (issueTypeData) in
                let issueType = JIRAIssueType()
                issueType.applyData(data: issueTypeData)
                issueTypesOutput.append(issueType)
            })
            self.issueTypes = issueTypesOutput
        }
    }
    
    override func export() -> Any? {
        return ["id":id ?? "","name":name ?? ""]
    }
}
