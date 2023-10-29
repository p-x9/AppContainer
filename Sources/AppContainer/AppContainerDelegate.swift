//
//  AppContainerDelegate.swift
//  
//
//  Created by p-x9 on 2023/03/06.
//  
//

import Foundation

public protocol AppContainerDelegate: AnyObject {
    /// Method called just before the container is switched.
    ///
    ///
    /// - Parameters:
    ///   - appContainer: AppContainer
    ///   - toContainer: Container to which to switch
    ///   - fromContainer: Container from which to switch
    func appContainer(_ appContainer: AppContainer, willChangeTo toContainer: Container, from fromContainer: Container?)

    /// Method called just after the container is switched.
    ///
    ///
    /// - Parameters:
    ///   - appContainer: AppContainer
    ///   - toContainer: Container to which to switch
    ///   - fromContainer: Container from which to switch
    func appContainer(_ appContainer: AppContainer, didChangeTo toContainer: Container, from fromContainer: Container?)
}

extension AppContainerDelegate {
    public func appContainer(_ appContainer: AppContainer, willChangeTo toContainer: Container, from fromContainer: Container?) {}
    public func appContainer(_ appContainer: AppContainer, didChangeTo toContainer: Container, from fromContainer: Container?) {}
}
