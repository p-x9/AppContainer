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

extension FileManager {
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

            if !src.shouldExclude(excludes: excludes) {
                if isDirectory(src) {
                    try createDirectoryIfNotExisted(at: dst, withIntermediateDirectories: true)
                    try moveChildContents(at: src, to: dst, excludes: excludes)
                } else {
                    try self.moveItem(at: src, to: dst)
                }
            }
        }
    }

    func moveChildContents(atPath srcPath: String, toPath dstPath: String, excludes: [String] = []) throws {
        let srcURL = URL(fileURLWithPath: srcPath)
        let dstURL = URL(fileURLWithPath: dstPath)

        try self.moveChildContents(at: srcURL, to: dstURL, excludes: excludes)
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

            if !src.shouldExclude(excludes: excludes) {
                if isDirectory(src) {
                    try self.createDirectoryIfNotExisted(at: dstURL, withIntermediateDirectories: true)
                    try self.copyChildContents(at: srcURL, to: dstURL, excludes: excludes)
                } else {
                    try self.copyItem(at: src, to: dst)
                }
            }
        }
    }

    func copyChildContents(atPath srcPath: String, toPath dstPath: String, excludes: [String] = []) throws {
        let srcURL = URL(fileURLWithPath: srcPath)
        let dstURL = URL(fileURLWithPath: dstPath)

        try self.copyChildContents(at: srcURL, to: dstURL, excludes: excludes)
    }

    func removeChildContents(at URL: URL, excludes: [String] = [], level: Int = 0) throws {
        guard self.fileExists(atPath: URL.path) else {
            return
        }

        let contents = try self.contentsOfDirectory(atPath: URL.path)
            .filter {
                $0 != Constants.containerFolderName && !excludes.contains($0)
            }

        let contentName = URL.lastPathComponent
        if contents.isEmpty,
           contentName != Constants.containerFolderName,
           !URL.shouldExclude(excludes: excludes),
           level > 0 {
            try self.removeItem(at: URL)
        }

        try contents.forEach {
            let URL = URL.appendingPathComponent($0)

            if !URL.shouldExclude(excludes: excludes) {
                if isDirectory(URL) {
                    try self.removeChildContents(at: URL, excludes: excludes, level: level + 1)
                } else {
                    try self.removeItem(at: URL)
                }
            }
        }
    }

    func removeChildContents(atPath path: String, excludes: [String] = []) throws {
        let URL = URL(fileURLWithPath: path)
        try self.removeChildContents(at: URL, excludes: excludes)
    }
}

extension FileManager {
    func isDirectory(_ path: String) -> Bool {
        var isDir: ObjCBool = false
        if fileExists(atPath: path, isDirectory: &isDir) {
            if isDir.boolValue {
                return true
            }
        }
        return false
    }

    func isDirectory(_ url: URL) -> Bool {
        var isDir: ObjCBool = false
        if fileExists(atPath: url.path, isDirectory: &isDir) {
            if isDir.boolValue {
                return true
            }
        }
        return false
    }
}

extension URL {
    func shouldExclude(excludes: [String]) -> Bool {
        for exclude in excludes {
            if path.hasSuffix(exclude) {
                return true
            }
        }
        return false
    }
}
