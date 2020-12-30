//
//  AppIconGenerator.swift
//  
//
//  Created by Fabrio-Leon on 2020/12/29.
//

import Foundation

public final class AppIconGenerator {
    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        print("arguments:\(arguments)")
        guard arguments.count > 1 else {
            throw Error.missingFile
        }
        let inputPath = arguments[1]
        let imputURL = URL(fileURLWithPath: inputPath)
        let appIcon = try generateAppIcon()
        let image = try generateOriginImage(url: imputURL)

        try createFile(appIcon: appIcon, image: image)
    }

    private func generateAppIcon() throws -> AppIconItem {
        print("generating AppIcon model")
        guard let data = jsonString.data(using: .utf8) else {
            throw Error.jsonStringToDataError
        }
        return try JSONDecoder().decode(AppIconItem.self, from: data)
    }

    private func generateOriginImage(url: URL) throws -> CGImage {
        print("generating origin image")
        let data = try Data(contentsOf: url)
        guard let provider = CGDataProvider(data: data as CFData),
              let image = CGImage(pngDataProviderSource: provider,
                                  decode: nil,
                                  shouldInterpolate: true,
                                  intent: .defaultIntent) else {
            throw Error.notPNGFile
        }

        guard image.width == 1024,
              image.height == 1024 else {
            throw Error.errorSize
        }
        return image
    }

    private func createFile(appIcon: AppIconItem, image: CGImage) throws {
        print("creating file")
        let fileManager = FileManager.default
        let appiconsetPath = fileManager.currentDirectoryPath + "/AppIcon.appiconset"
        if fileManager.fileExists(atPath: appiconsetPath) {
            try fileManager.removeItem(atPath: appiconsetPath)
        }
        try fileManager.createDirectory(atPath: appiconsetPath,
                                        withIntermediateDirectories: true,
                                        attributes: nil)
        let contentsPath = appiconsetPath  + "/contents.json"
        try jsonString.write(toFile: contentsPath, atomically: true, encoding: .utf8)

        try appIcon.images.forEach { try createImage(imageItem: $0, image: image) }
    }

    private func createImage(imageItem: AppIconImageItem, image: CGImage) throws {
        print("creating image:\(imageItem.filename)")
        let scale = try imageItem.getScale()
        let width = try imageItem.getSize().width
        let imageWidth = Int(round(Double(width) * Double(scale)))
        guard let context = CGContext(data: nil,
                                      width: imageWidth, height: imageWidth,
                                      bitsPerComponent: image.bitsPerComponent,
                                      bytesPerRow: image.bytesPerRow,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            throw Error.generateContextError
        }
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageWidth))
        guard let outputImage = context.makeImage() else {
            throw Error.makeImageError
        }
        let outputURL = URL(fileURLWithPath: "AppIcon.appiconset/\(imageItem.filename)") as CFURL
        guard let destination = CGImageDestinationCreateWithURL(outputURL, kUTTypePNG, 1, nil) else {
            throw Error.generateDestinationError
        }
        CGImageDestinationAddImage(destination, outputImage, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw Error.finalizeDestinationError
        }
    }
}

extension AppIconGenerator {
    enum Error: Swift.Error {
        case missingPath
        case missingFile
        case notPNGFile
        case errorSize
        case decodeImageSizeError
        case decodeImageScaleError
        case jsonStringToDataError
        case generateDestinationError
        case finalizeDestinationError
        case generateContextError
        case makeImageError
    }

    struct AppIconItem: Codable {
        var images: [AppIconImageItem]
    }

    struct AppIconImageItem: Codable {
        var filename: String
        var idiom: String
        var scale: String
        var size: String

        func getSize() throws -> CGSize {
            guard let widthStr = size.components(separatedBy: "x").first,
                  let width = Double(widthStr) else {
                throw Error.decodeImageSizeError
            }
            return CGSize(width: width, height: width)
        }

        func getScale() throws -> Int {
            guard let scaleStr = scale.components(separatedBy: "x").first,
                  let scaleValue = Int(scaleStr) else {
                throw Error.decodeImageScaleError
            }
            return scaleValue
        }
    }
}

private let jsonString =
"""
{
  "images" : [
    {
      "filename" : "Icon-App-20x20@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-App-20x20@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-App-29x29@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-App-29x29@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-App-40x40@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-App-40x40@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-App-60x60@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-App-60x60@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-iPad-20x20@1x.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-iPad-20x20@2x-1.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-iPad-29x29@1x.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-iPad-29x29@2x-1.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-iPad-40x40@1x.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-iPad-40x40@2x-1.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-iPad-76x76@1x.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-iPad-76x76@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-iPad-83.5x83.5@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "filename" : "ItunesArtwork@2x.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}

"""
