//
//  IssuerIntroductionRequest.swift
//  cert-wallet
//
//  Created by Chris Downie on 9/2/16.
//  Copyright © 2016 Digital Certificates Project. All rights reserved.
//

import Foundation

class IssuerIntroductionRequest {
    var callback : ((Bool, String?) -> Void)?
    let url : URL
    
    private var session : URLSessionProtocol
    private var currentTask : URLSessionDataTaskProtocol?
    
    init(introduce recipient: Recipient, to issuer: Issuer, session: URLSessionProtocol = URLSession.shared, callback: ((Bool, String?) -> Void)?) {
        self.callback = callback
        self.session = session
        // TODO: It may not make sense for these additional properties to be optional. Investigate so I can remove this force-unwrap.
        url = issuer.requestUrl!
    }
    
    func start() {
        currentTask = session.dataTask(with: url) { [weak self] (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                    self?.reportFailure("Server responded with non-200 status.")
                    return
            }
            
            self?.reportSuccess()
        }
        currentTask?.resume()
    }
    
    func abort() {
        currentTask?.cancel()
        reportFailure("Aborted")
    }
    
    private func reportFailure(_ reason: String) {
        callback?(false, reason)
        callback = nil
    }
    
    private func reportSuccess() {
        callback?(true, nil)
        callback = nil
    }
}