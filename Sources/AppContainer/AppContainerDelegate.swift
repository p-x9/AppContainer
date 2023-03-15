//
//  AppContainerDelegate.swift
//  
//
//  Created by p-x9 on 2023/03/06.
//  
//

import Foundation

public protocol AppContainerDelegate: AnyObject {
    func appContainer(_ appContainer: AppContainer, willChangeTo toContainer: Container, from fromContainer: Container?)
    func appContainer(_ appContainer: AppContainer, didChangeTo toContainer: Container, from fromContainer: Container?)
}

extension AppContainerDelegate {
    public func appContainer(_ appContainer: AppContainer, willChangeTo toContainer: Container, from fromContainer: Container?) {}
    public func appContainer(_ appContainer: AppContainer, didChangeTo toContainer: Container, from fromContainer: Container?) {}
}
