//
//  UserAgentPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public class UserAgentPolicy: PipelineStageProtocol {
    public var next: PipelineStageProtocol?

    private var _userAgent: String

    public let userAgentOverwrite: Bool
    public var userAgent: String {
        return _userAgent
    }

    public init(baseUserAgent: String? = nil, userAgentOverwrite: Bool = false) {
        // TODO: User-Agent format according to SDK guidelines
        // [<application_id> ]azsdk-<sdk_language>-<package_name>/<package_version> <platform_info>
        // [Application/Version] azsdk-ios-AppConfiguration/0.1.0
        //   (Swift BLAH; ObjC BLAH; Macintosh; Intel Max OS X 10_10; rv:33.0)
        self.userAgentOverwrite = userAgentOverwrite
        if baseUserAgent == nil {
            // TODO: Distinguish between Swift and ObjC?
            let swiftVersion = 5.0
            let platform = "iPhone"
            let azureCoreVersion = "0.1.0"
            _userAgent = "ios/\(swiftVersion) (\(platform)) AzureCore/\(azureCoreVersion)"
        } else {
            _userAgent = baseUserAgent!
        }
    }

    public func appendUserAgent(value: String) {
        _userAgent = "\(_userAgent) \(value)"
    }

    public func onRequest(_ request: inout PipelineRequest) {
        if let contextUserAgent = request.context?.value(forKey: "userAgent") as? String {
            if request.context?.value(forKey: "userAgentOverwrite") != nil {
                request.httpRequest.headers[.userAgent] = contextUserAgent
            } else {
                request.httpRequest.headers[.userAgent] = "\(userAgent) \(contextUserAgent)"
            }
        } else if userAgentOverwrite || request.httpRequest.headers[HttpHeader.userAgent] == nil {
            request.httpRequest.headers[.userAgent] = userAgent
        }
    }
}
