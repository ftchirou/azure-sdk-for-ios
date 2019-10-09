//
//  AuthenticationPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public class AccessToken {
    public let token: String
    public let expiresOn: Int

    public init(token: String, expiresOn: Int) {
        self.token = token
        self.expiresOn = expiresOn
    }
}

public protocol TokenCredential {
    func getToken(forScopes scopes: [String]) -> AccessToken?
}

public protocol AuthenticationProtocol: PipelineStageProtocol {
    func authenticate(request: PipelineRequest)
}

extension AuthenticationProtocol {
    public func onRequest(_ request: inout PipelineRequest) {
        authenticate(request: request)
    }
}

public class BearerTokenCredentialPolicy: AuthenticationProtocol {
    public var next: PipelineStageProtocol?

    public let scopes: [String]
    public let credential: TokenCredential
    public var needNewToken: Bool {
        // TODO: Also if token expires within 300... ms?
        return (token == nil)
    }

    private var token: AccessToken?

    public init(credential: TokenCredential, scopes: [String]) {
        self.scopes = scopes
        self.credential = credential
        token = nil
    }

    public func authenticate(request: PipelineRequest) {
        if let token = self.token?.token {
            request.httpRequest.headers[.authorization] = "Bearer \(token)"
        }
    }

    public func onRequest(_ request: inout PipelineRequest) {
        if needNewToken {
            token = credential.getToken(forScopes: scopes)
        }
        authenticate(request: request)
    }
}
