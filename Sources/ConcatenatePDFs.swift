// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import ArgumentParser
import CoreGraphics

@main
struct ConcatenatePDFs: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Concatenates PDFs into one PDF file.",
        usage: """
            concatenate_pdfs -d concatenated.pdf first.pdf second.pdf third.pdf
        """,
        version: "1.0.0"
    )
    
    @Option(name: .shortAndLong, help: "Destination path for concatenated PDF")
    var destPath: String
    
    @Argument(parsing: .remaining,
              help: "Paths to source PDFs to concatenate",
              completion: .file(extensions: ["pdf"]))
    var sourcePDFPaths: [String]

    
    mutating func run() throws {
        let fm = FileManager.default
        let wd = fm.currentDirectoryPath
        print("working directory: \(wd)")
        
        guard sourcePDFPaths.count > 0 else {
            FileHandle.standardError.write("no source pdf files specified".data(using: .utf8)!)
            return
        }
        
        
        // set up destination
        let destURL = URL(fileURLWithPath: destPath)
        do {
            let destFolder = destURL.deletingLastPathComponent()
            try fm.createDirectory(at: destFolder, withIntermediateDirectories: true)
        } catch let error {
            FileHandle.standardError.write("error creating destination folder: \(error)".data(using: .utf8)!)
            return
        }
        
        // NOTE: may want to use media box from first PDF?
        guard let destContext = CGContext(destURL as CFURL, mediaBox: nil, nil) else {
            FileHandle.standardError.write("error opening PDF context".data(using: .utf8)!)
            return
        }
        
        for sourcePath in sourcePDFPaths {
            let sourceURL = URL(fileURLWithPath: sourcePath)
            guard let sourcePDF = CGPDFDocument(sourceURL as CFURL) else {
                FileHandle.standardError.write("error opening source \(sourcePath)".data(using: .utf8)!)
                continue
            }
            
            print("concatenating \(sourcePath)...")
            
            for pagenum in 1...sourcePDF.numberOfPages {
                if let page = sourcePDF.page(at: pagenum) {
                    destContext.beginPDFPage(nil)
                    destContext.drawPDFPage(page)
                    destContext.endPDFPage()
                }
            }
        }
        
        destContext.closePDF()
    }
    
}

//ConcatenatePDFs.main()
