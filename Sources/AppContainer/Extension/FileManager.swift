//
//  FileManager.swift
//
//
//  Created by p-x9 on 2022/09/08.
//
//

import Foundation

extension FileManager {
    // swiftlint:disable:next discouraged_optional_collection
    func createDirectoryIfNotExisted(at url: URL, withIntermediateDirectories: Bool, attributes: [FileAttributeKey: Any]? = nil) throws {
        guard !self.fileExists(atPath: url.path) else {
            return
        }

        try self.createDirectory(at: url,
                                 withIntermediateDirectories: withIntermediateDirectories,
                                 attributes: attributes)
    }

    // swiftlint:disable:next discouraged_optional_collection
    func createDirectoryIfNotExisted(atPath path: String, withIntermediateDirectories: Bool, attributes: [FileAttributeKey: Any]? = nil) throws {
        guard !self.fileExists(atPath: path) else {
            return
        }

        try self.createDirectory(atPath: path,
                                 withIntermediateDirectories: withIntermediateDirectories,
                                 attributes: attributes)
    }

    func moveItemIfExisted(at srcURL: URL, to dstURL: URL) throws {
        guard self.fileExists(atPath: srcURL.path) else {
            return
        }

        if self.fileExists(atPath: dstURL.path) {
            try self.removeItem(at: dstURL)
        }

        try self.moveItem(at: srcURL, to: dstURL)
    }

    func moveItemIfExisted(atPath srcPath: String, toPath dstPath: String) throws {
        guard self.fileExists(atPath: srcPath) else {
            return
        }

        if self.fileExists(atPath: dstPath) {
            try self.removeItem(atPath: dstPath)
        }

        try self.moveItem(atPath: srcPath, toPath: dstPath)
    }

    func moveChildContents(at srcURL: URL, to dstURL: URL, excludes: [String] = []) throws {
        guard self.fileExists(atPath: srcURL.path) else {
            return
        }

        let contents = try self.contentsOfDirectory(atPath: srcURL.path)
            .filter {
                $0 != Constants.containerFolderName && !excludes.contains($0)
            }

        try contents.forEach {
            let src = srcURL.appendingPathComponent($0)
            let dst = dstURL.appendingPathComponent($0)

            try self.moveItem(at: src, to: dst)
        }
    }

    func moveChildContents(atPath srcPath: String, toPath dstPath: String, excludes: [String] = []) throws {
        guard self.fileExists(atPath: srcPath) else {
            return
        }

        let contents = try self.contentsOfDirectory(atPath: srcPath)
            .filter {
                $0 != Constants.containerFolderName && !excludes.contains($0)
            }

        try contents.forEach {
            let src = srcPath + "/" + $0
            let dst = dstPath + "/" + $0

            try self.moveItem(atPath: src, toPath: dst)
        }
    }

    func copyChildContents(at srcURL: URL, to dstURL: URL, excludes: [String] = []) throws {
        guard self.fileExists(atPath: srcURL.path) else {
            return
        }

        let contents = try self.contentsOfDirectory(atPath: srcURL.path)
            .filter {
                $0 != Constants.containerFolderName && !excludes.contains($0)
            }

        try contents.forEach {
            let src = srcURL.appendingPathComponent($0)
            let dst = dstURL.appendingPathComponent($0)

            try self.copyItem(at: src, to: dst)
        }
    }

    func copyChildContents(atPath srcPath: String, toPath dstPath: String, excludes: [String] = []) throws {
        guard self.fileExists(atPath: srcPath) else {
            return
        }

        let contents = try self.contentsOfDirectory(atPath: srcPath)
            .filter {
                $0 != Constants.containerFolderName && !excludes.contains($0)
            }

        try contents.forEach {
            let src = srcPath + "/" + $0
            let dst = dstPath + "/" + $0

            try self.copyItem(atPath: src, toPath: dst)
        }
    }

    func removeChildContents(at URL: URL, excludes: [String] = []) throws {
        guard self.fileExists(atPath: URL.path) else {
            return
        }

        let contents = try self.contentsOfDirectory(atPath: URL.path)
            .filter {
                $0 != Constants.containerFolderName && !excludes.contains($0)
            }

        try contents.forEach {
            try self.removeItem(at: URL.appendingPathComponent($0))
        }
    }

    func removeChildContents(atPath path: String, excludes: [String] = []) throws {
        guard self.fileExists(atPath: path) else {
            return
        }

        let contents = try self.contentsOfDirectory(atPath: path)
            .filter {
                $0 != Constants.containerFolderName && !excludes.contains($0)
            }

        try contents.forEach {
            try self.removeItem(atPath: path + "/" + $0)
        }
    }

    func removeItemIfExisted(at URL: URL) throws {
        guard self.fileExists(atPath: URL.path) else {
            return
        }

        try self.removeItem(at: URL)
    }

    func removeItemIfExisted(atPath path: String) throws {
        guard self.fileExists(atPath: path) else {
            return
        }

        try self.removeItem(atPath: path)
    }
}
