//
//  FileManager+AppleArchive.swift
//  StableDiffusionDesktop
//
//  Created by Simon Whitaker on 02/01/2023.
//

import AppleArchive
import Foundation
import System

enum FileManagerArchiveError: Error {
    case invalidArchiveFileURL
}

extension FileManager {
    func unarchiveItems(at archiveFile: URL, to destinationDirectory: URL) throws {
        // See https://developer.apple.com/documentation/accelerate/decompressing_and_extracting_an_archived_directory

        guard let archiveFilePath = FilePath(archiveFile) else {
            throw FileManagerArchiveError.invalidArchiveFileURL
        }

        // Create the File Stream to Read the Source Archive
        guard let readFileStream = ArchiveByteStream.fileStream(
            path: archiveFilePath,
            mode: .readOnly,
            options: [],
            permissions: FilePermissions(rawValue: 0o644)) else {
            print("Call to ArchiveByteStream.fileStream failed")
            return
        }
        defer {
            try? readFileStream.close()
        }

        // Create the Decompression Stream
        guard let decompressStream = ArchiveByteStream.decompressionStream(readingFrom: readFileStream) else {
            print("Call to ArchiveByteStream.decompressionStream failed")
            return
        }
        defer {
            try? decompressStream.close()
        }

        // Create the Decoding Stream
        guard let decodeStream = ArchiveStream.decodeStream(readingFrom: decompressStream) else {
            print("Call to ArchiveStream.decodeStream failed")
            return
        }
        defer {
            try? decodeStream.close()
        }

        // Specify the Destination
        let decompressDestination = FilePath(destinationDirectory.path())

        // Create the destination, if needed
        do {
            try self.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)
        } catch {
            print("On creating cached model directory: \(error)")
            throw error
        }

        // Create the extract stream
        guard let extractStream = ArchiveStream.extractStream(extractingTo: decompressDestination, flags: [.ignoreOperationNotPermitted]) else {
            print("Call to ArchiveStream.extractStream failed")
            return
        }
        defer {
            try? extractStream.close()
        }

        // Decompress and Extract the Archived Directory
        do {
            _ = try ArchiveStream.process(readingFrom: decodeStream, writingTo: extractStream)
        } catch {
            print("Call to ArchiveStream.process failed")
            throw error
        }
    }
}
