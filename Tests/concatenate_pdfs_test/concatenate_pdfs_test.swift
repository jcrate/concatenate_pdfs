import XCTest
import class Foundation.Bundle

final class concatenate_pdfs_test: XCTestCase {
    
        
    func testToolWithFile() throws {
        let binaryURL = productsDirectory.appendingPathComponent("concatenate_pdfs")
        
        let process = Process()
        process.executableURL = binaryURL
        
        let destURL = tmpDir.appending(component: "concatenated1.pdf", directoryHint: .notDirectory)
        process.arguments = ["-d", "\(destURL.path)", singlePagePDFURL.path, multiPagePDFURL.path]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()
        
        NSWorkspace.shared.open(tmpDir)
        XCTAssert(FileManager.default.fileExists(atPath: destURL.path), "Concatenated PDF should exist.")
        
        let sourcePages = pages(for: singlePagePDFURL) + pages(for: multiPagePDFURL)
        let destPages = pages(for: destURL)
        XCTAssertEqual(sourcePages, destPages, "Concatenated PDF should have same number of pages as source PDFs")
    }
    

    

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
    
    var resourceURL: URL {
        Bundle.module.bundleURL.appendingPathComponent("Contents/Resources/", isDirectory: true)
    }

    
    /// helpers
    var singlePagePDFURL : URL {
        resourceURL.appendingPathComponent("pdfs/single-page.pdf", isDirectory: false)
    }
    var multiPagePDFURL : URL {
        resourceURL.appendingPathComponent("pdfs/multi-page.pdf", isDirectory: false)
    }
    
    var tmpDir : URL {
        let fm = FileManager.default
        let tmpDir = fm.temporaryDirectory.appendingPathComponent("concatenate_pdfs_test", isDirectory: true)
        try? fm.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        return tmpDir
    }
    
    func pages(for pdfURL: URL) -> Int {
        guard let pdf = CGPDFDocument(pdfURL as CFURL) else {
            return 0
        }
        return pdf.numberOfPages
    }

}
