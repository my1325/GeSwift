//
//  AppleSign.swift
//  JokyNote
//
//  Created by mayong on 2023/11/28.
//

import AuthenticationServices
import Combine
import Foundation

public struct AppleLoginResposne {
    public let nickName: String
    public let openId: String
    public let email: String
    public let code: String
    public let token: String
}

public struct ASAuthorizationAppleIDPublisher: Publisher {
    public typealias Output = AppleLoginResposne
    public typealias Failure = Error
    
    let anchor: ASPresentationAnchor
    let request: ASAuthorizationAppleIDProvider
    init(_ presentationAnchor: ASPresentationAnchor, request: ASAuthorizationAppleIDProvider) {
        self.request = request
        self.anchor = presentationAnchor
    }
    
    private final class ASAuthorizationAppleIDSubscription<S: Subscriber>: NSObject, Subscription, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding where S.Input == AppleLoginResposne, S.Failure == Error
    {
        let presentationAnchor: ASPresentationAnchor
        let request: ASAuthorizationAppleIDProvider
        let subscriber: S
        var retainSelf: ASAuthorizationAppleIDSubscription?
        init(_ presentationAnchor: ASPresentationAnchor,
             request: ASAuthorizationAppleIDProvider,
             subscriber: S)
        {
            self.presentationAnchor = presentationAnchor
            self.request = request
            self.subscriber = subscriber
            super.init()
            self.retainSelf = self
        }

        func request(_ demand: Subscribers.Demand) {
            let _request = request.createRequest()
            _request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [_request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
        
        func cancel() {
            retainSelf = nil
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            subscriber.receive(completion: .failure(error))
        }
//        bytes.reduce("", { $0.appendingFormat("%02x", $1 & 0xff) })
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let nickName = (appleIDCredential.fullName?.familyName ?? "") + (appleIDCredential.fullName?.givenName ?? "")
                let retResponse = AppleLoginResposne(nickName: nickName,
                                                     openId: appleIDCredential.user,
                                                     email: appleIDCredential.email ?? "",
                                                     code: Array(appleIDCredential.authorizationCode ?? Data()).reduce("", { $0.appendingFormat("%02x", $1 & 0xff) }),
                                                     token: Array(appleIDCredential.identityToken ?? Data()).reduce("", { $0.appendingFormat("%02x", $1 & 0xff) }))
                _ = subscriber.receive(retResponse)
                subscriber.receive(completion: .finished)
            } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
                // Sign in using an existing iCloud Keychain credential.
                _ = passwordCredential.user
                _ = passwordCredential.password
            }
        }
        
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return presentationAnchor
        }
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, AppleLoginResposne == S.Input {
        subscriber.receive(subscription: ASAuthorizationAppleIDSubscription(anchor, request: request, subscriber: subscriber))
    }
}

public extension ASAuthorizationAppleIDProvider {
    func requestPublisher(_ anchor: ASPresentationAnchor) -> AnyPublisher<AppleLoginResposne, Error> {
        ASAuthorizationAppleIDPublisher(anchor, request: self)
            .eraseToAnyPublisher()
    }
}
