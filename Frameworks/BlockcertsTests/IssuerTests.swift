//
//  IssuerTests.swift
//  cert-wallet
//
//  Created by Chris Downie on 8/25/16.
//  Copyright © 2016 Digital Certificates Project. All rights reserved.
//

import XCTest
@testable import Blockcerts

class IssuerTests: XCTestCase {
    let nameValue = "Name"
    let emailValue = "Email"
    let imageDataValue = ""
    let idValue = "https://example.com/id"
    let urlValue = "https://example.com/url"
    let publicKeyValue = "BadPublicKey"
    let introductionURLValue = "https://example.com/request"
    let introductionURLSuccessValue = "https://example.com/request/success"
    let introductionURLErrorValue = "https://example.com/request/error"
    let analyticsURLValue = "https://example.com/analytics/data"
    let issuerKey = KeyRotation(on: Date(timeIntervalSince1970: 0), key: "ISSUER_KEY")
    let revocationKey = KeyRotation(on: Date(timeIntervalSince1970: 0), key: "REVOCATION_KEY")
    
    func testDictionaryConversion() {
        let issuer = IssuerV1(name: nameValue,
                            email: emailValue,
                            image: Data(),
                            id: URL(string: idValue)!,
                            url: URL(string: urlValue)!,
                            publicIssuerKeys: [issuerKey],
                            publicRevocationKeys: [revocationKey],
                            introductionURL: URL(string: introductionURLValue)!)
        
        let expectedIssuerKeys : [[String: String]] = [
            [
                "date": issuerKey.on.toString(),
                "key": issuerKey.key.scopedValue
            ]
        ]
        let expectedRevocationKeys : [[String: String]] = [
            [
                "date": revocationKey.on.toString(),
                "key": revocationKey.key.scopedValue
            ]
        ]
        
        let result = issuer.toDictionary()
        XCTAssertEqual(result["name"] as! String, nameValue)
        XCTAssertEqual(result["email"] as! String, emailValue)
        XCTAssertEqual(result["image"] as! String, "data:image/png;base64,\(imageDataValue)")
        XCTAssertEqual(result["id"] as! String, idValue)
        XCTAssertEqual(result["url"] as! String, urlValue)
        XCTAssertEqual(result["introductionAuthenticationMethod"] as! String, "basic")
        XCTAssertEqual(result["introductionURL"] as! String, introductionURLValue)
        
        let issuerKeys = result["issuerKeys"] as! [[String: String]]
        XCTAssertEqual(issuerKeys.count, 1)
        XCTAssertEqual(issuerKeys.first!, expectedIssuerKeys.first!)
        
        let revocationKeys = result["revocationKeys"] as! [[String: String]]
        XCTAssertEqual(revocationKeys.count, 1)
        XCTAssertEqual(revocationKeys.first!, expectedRevocationKeys.first!)
    }
    
    func testDictionaryInitialization() {
        let input : [String : Any] = [
            "name": nameValue,
            "email": emailValue,
            "image": "data:image/png;base64,\(imageDataValue)",
            "id": idValue,
            "url": urlValue,
            "publicKey": publicKeyValue,
            "introductionURL": introductionURLValue,
            "issuerKeys": [
                [
                    "date": issuerKey.on.toString(),
                    "key": issuerKey.key.scopedValue
                ]
            ],
            "revocationKeys": [
                [
                    "date": revocationKey.on.toString(),
                    "key": revocationKey.key.scopedValue
                ]
            ]

        ]
        let expectedResult = IssuerV1(name: nameValue,
                                      email: emailValue,
                                      image: Data(),
                                      id: URL(string: idValue)!,
                                      url: URL(string: urlValue)!,
                                      publicIssuerKeys: [issuerKey],
                                      publicRevocationKeys: [revocationKey],
                                      introductionURL: URL(string: introductionURLValue)!)
        let result = try? IssuerParser.parse(dictionary: input, asVersion: .one)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result as? IssuerV1, expectedResult)
    }
    
    func testDictionaryConversionWithWebAuthentication() {
        let introductionMethod = IssuerIntroductionMethod.webAuthentication(introductionURL: URL(string: introductionURLValue)!,
                                                                            successURL: URL(string: introductionURLSuccessValue)!,
                                                                            errorURL: URL(string: introductionURLErrorValue)!)
        let issuer = IssuerV2Alpha(name: nameValue,
                                   email: emailValue,
                                   image: Data(),
                                   id: URL(string: idValue)!,
                                   url: URL(string: urlValue)!,
                                   publicKeys: [issuerKey],
                                   introductionMethod: introductionMethod,
                                   analyticsURL: URL(string: analyticsURLValue)!)
        
        let result = issuer.toDictionary()
        XCTAssertEqual(result["introductionAuthenticationMethod"] as! String, "web")
        XCTAssertEqual(result["introductionURL"] as! String, introductionURLValue)
        XCTAssertEqual(result["introductionSuccessURL"] as! String, introductionURLSuccessValue)
        XCTAssertEqual(result["introductionErrorURL"] as! String, introductionURLErrorValue)
    }
    
    
    func testDictionaryInitializationWithWebAuthentication() {
        let input : [String : Any] = [
            "name": nameValue,
            "email": emailValue,
            "image": "data:image/png;base64,\(imageDataValue)",
            "id": idValue,
            "url": urlValue,
            "publicKey": publicKeyValue,
            "introductionAuthenticationMethod": "web",
            "introductionURL": introductionURLValue,
            "introductionSuccessURL": introductionURLSuccessValue,
            "introductionErrorURL": introductionURLErrorValue,
            "issuerKeys": [
                [
                    "date": issuerKey.on.toString(),
                    "key": issuerKey.key.scopedValue
                ]
            ],
            "revocationKeys": [
                [
                    "date": revocationKey.on.toString(),
                    "key": revocationKey.key.scopedValue
                ]
            ]
            
        ]
        let introductionMethod = IssuerIntroductionMethod.webAuthentication(introductionURL: URL(string: introductionURLValue)!,
                                                                            successURL: URL(string: introductionURLSuccessValue)!,
                                                                            errorURL: URL(string: introductionURLErrorValue)!)
        let expectedResult = IssuerV1(name: nameValue,
                                    email: emailValue,
                                    image: Data(),
                                    id: URL(string: idValue)!,
                                    url: URL(string: urlValue)!,
                                    publicIssuerKeys: [issuerKey],
                                    publicRevocationKeys: [revocationKey],
                                    introductionMethod: introductionMethod)
        let result = try? IssuerParser.parse(dictionary: input, asVersion: .one)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result as? IssuerV1, expectedResult)
    }
    
    
    func testDictionaryInitializationBackwardsCompatibility() {
        let input : [String : Any] = [
            "name": nameValue,
            "email": emailValue,
            "image": "data:image/png;base64,\(imageDataValue)",
            "id": idValue,
            "url": urlValue,
            "publicKey": publicKeyValue,
            "introductionURL": introductionURLValue,
            "issuerKeys": [
                [
                    "date": issuerKey.on.toString(),
                    "key": issuerKey.key.scopedValue
                ]
            ],
            "revocationKeys": [
                [
                    "date": revocationKey.on.toString(),
                    "key": revocationKey.key.scopedValue
                ]
            ]
            
        ]
        let result = try? IssuerParser.parse(dictionary: input, asVersion: .one)
        
        XCTAssertNotNil(result)
        
        let expectedMethod = IssuerIntroductionMethod.basic(introductionURL: URL(string:introductionURLValue)!)
        XCTAssertEqual(result?.introductionMethod, expectedMethod)
    }
    
    
    func testDictionaryWithIntroMethodMismatch() {
        let input : [String : Any] = [
            "name": nameValue,
            "email": emailValue,
            "image": "data:image/png;base64,\(imageDataValue)",
            "id": idValue,
            "url": urlValue,
            "publicKey": publicKeyValue,
            "introductionAuthenticationMethod": "web",
            "introductionURL": introductionURLValue,
            "issuerKeys": [
                [
                    "date": issuerKey.on.toString(),
                    "key": issuerKey.key.scopedValue
                ]
            ],
            "revocationKeys": [
                [
                    "date": revocationKey.on.toString(),
                    "key": revocationKey.key.scopedValue
                ]
            ]
            
        ]
        let result = IssuerParser.parse(dictionary: input)
        
        XCTAssertNotNil(result)
        
        XCTAssertEqual(result?.introductionMethod, IssuerIntroductionMethod.unknown)
    }
    
    func testVersionDetectionForV1() {
        let input : [String : Any] = [
            "name": nameValue,
            "email": emailValue,
            "image": "data:image/png;base64,\(imageDataValue)",
            "id": idValue,
            "url": urlValue,
            "publicKey": publicKeyValue,
            "introductionURL": introductionURLValue,
            "issuerKeys": [
                [
                    "date": issuerKey.on.toString(),
                    "key": issuerKey.key.scopedValue
                ]
            ],
            "revocationKeys": [
                [
                    "date": revocationKey.on.toString(),
                    "key": revocationKey.key.scopedValue
                ]
            ]
            
        ]
        
        let issuer = IssuerParser.parse(dictionary: input)
        XCTAssertEqual(issuer?.version, .one)
    }
    
    func testVersionDetectionForV2Alpha() {
        let issuerData : [String : Any] = [
            "@context": ["https://openbadgespec.org/v2/context.json", "https://www.blockcerts.org/schema/2.0-alpha/context.json"],
            "type": "Profile",
            "id": idValue,
            "name": nameValue,
            "url": urlValue,
            "image": "data:image/png;base64,\(imageDataValue)",
            "email": emailValue,
            "publicKeys": [
                [
                    "publicKey": "ecdsa-koblitz-pubkey:n138AWR4d2srKgw57rWph8wibVSwZt2XDi",
                    "created": "2017-03-10T18:17:48.102+00:00"
                ]
            ],
            "introductionURL": introductionURLValue
        ]
        
        var issuer = IssuerParser.parse(dictionary: issuerData)
        XCTAssertEqual(issuer?.version, .twoAlpha)
        
        let issuerWithWebAuth : [String: Any] = [
            "@context": ["https://openbadgespec.org/v2/context.json", "https://www.blockcerts.org/schema/2.0-alpha/context.json"],
            "type": "Profile",
            "id": idValue,
            "name": nameValue,
            "url": urlValue,
            "image": "data:image/png;base64,\(imageDataValue)",
            "email": emailValue,
            "publicKeys": [
                [
                    "publicKey": "ecdsa-koblitz-pubkey:n138AWR4d2srKgw57rWph8wibVSwZt2XDi",
                    "created": "2017-03-10T18:17:48.102+00:00"
                ]
            ],
            "introductionAuthenticationMethod": "web",
            "introductionURL": introductionURLValue,
            "introductionSuccessURL": introductionURLSuccessValue,
            "introductionErrorURL": introductionURLErrorValue
        ]

        issuer = IssuerParser.parse(dictionary: issuerWithWebAuth)
        XCTAssertEqual(issuer?.version, .twoAlpha)
    }
    
    func testVersionDetectionForV2() {
        let issuerData : [String : Any] = [
            "@context": ["https://openbadgespec.org/v2/context.json", "https://www.blockcerts.org/schema/2.0-alpha/context.json"],
            "type": "Profile",
            "id": idValue,
            "name": nameValue,
            "url": urlValue,
            "image": "data:image/png;base64,\(imageDataValue)",
            "email": emailValue,
            "publicKey": [
                [
                    "id": "ecdsa-koblitz-pubkey:n138AWR4d2srKgw57rWph8wibVSwZt2XDi",
                    "created": "2017-03-10T18:17:48.102+00:00"
                ]
            ],
            "introductionURL": introductionURLValue
        ]
        
        var issuer = IssuerParser.parse(dictionary: issuerData)
        XCTAssertEqual(issuer?.version, .two)
        
        let issuerWithWebAuth : [String: Any] = [
            "@context": ["https://openbadgespec.org/v2/context.json", "https://www.blockcerts.org/schema/2.0-alpha/context.json"],
            "type": "Profile",
            "id": idValue,
            "name": nameValue,
            "url": urlValue,
            "image": "data:image/png;base64,\(imageDataValue)",
            "email": emailValue,
            "publicKey": [
                [
                    "id": "ecdsa-koblitz-pubkey:n138AWR4d2srKgw57rWph8wibVSwZt2XDi",
                    "created": "2017-03-10T18:17:48.102+00:00"
                ]
            ],
            "introductionAuthenticationMethod": "web",
            "introductionURL": introductionURLValue,
            "introductionSuccessURL": introductionURLSuccessValue,
            "introductionErrorURL": introductionURLErrorValue
        ]
        
        issuer = IssuerParser.parse(dictionary: issuerWithWebAuth)
        XCTAssertEqual(issuer?.version, .two)
    }
    
    func testDictionaryInitializationWithVersionDetection() {
        let issuerV1 : [String : Any] = [
            "name": nameValue,
            "email": emailValue,
            "image": "data:image/png;base64,\(imageDataValue)",
            "id": idValue,
            "url": urlValue,
            "publicKey": publicKeyValue,
            "introductionURL": introductionURLValue,
            "issuerKeys": [
                [
                    "date": issuerKey.on.toString(),
                    "key": issuerKey.key.scopedValue
                ]
            ],
            "revocationKeys": [
                [
                    "date": revocationKey.on.toString(),
                    "key": revocationKey.key.scopedValue
                ]
            ]
            
        ]
        let expectedResult = IssuerV1(name: nameValue,
                                    email: emailValue,
                                    image: Data(),
                                    id: URL(string: idValue)!,
                                    url: URL(string: urlValue)!,
                                    publicIssuerKeys: [issuerKey],
                                    publicRevocationKeys: [revocationKey],
                                    introductionURL: URL(string: introductionURLValue)!)
        let result = try? IssuerParser.parse(dictionary: issuerV1, asVersion: .one)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result as? IssuerV1, expectedResult)
        
        
        let publicKey = KeyRotation(on: Date(timeIntervalSince1970: 0), key: "n138AWR4d2srKgw57rWph8wibVSwZt2XDi")
        let issuerV2Alpha : [String: Any] = [
            "@context": ["https://openbadgespec.org/v2/context.json", "https://www.blockcerts.org/schema/2.0-alpha/context.json"],
            "type": "Profile",
            "id": idValue,
            "name": nameValue,
            "url": urlValue,
            "image": "data:image/png;base64,\(imageDataValue)",
            "email": emailValue,
            "publicKeys": [
                [
                    "publicKey": "ecdsa-koblitz-pubkey:\(publicKey.key)",
                    "created": publicKey.on.toString()
                ]
            ],
            "introductionAuthenticationMethod": "web",
            "introductionURL": introductionURLValue,
            "introductionSuccessURL": introductionURLSuccessValue,
            "introductionErrorURL": introductionURLErrorValue
        ]
        
        let resultV2Alpha = try? IssuerParser.parse(dictionary: issuerV2Alpha, asVersion: .twoAlpha)
        let webIntroduction = IssuerIntroductionMethod.webAuthentication(introductionURL: URL(string: introductionURLValue)!,
                                                                         successURL: URL(string: introductionURLSuccessValue)!,
                                                                         errorURL: URL(string: introductionURLErrorValue)!)
        
        
        let expectedResultV2Alpha = IssuerV2Alpha(name: nameValue,
                                      email: emailValue,
                                      image: Data(),
                                      id: URL(string: idValue)!,
                                      url: URL(string: urlValue)!,
                                      publicKeys: [publicKey],
                                      introductionMethod: webIntroduction,
                                      analyticsURL: URL(string: analyticsURLValue)!)
        XCTAssertNotNil(resultV2Alpha)
        XCTAssertEqual(resultV2Alpha as? IssuerV2Alpha, expectedResultV2Alpha)
    }
    
}
