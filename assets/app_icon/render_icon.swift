import AppKit
import CoreText

let outputPath = CommandLine.arguments.count > 1
  ? CommandLine.arguments[1]
  : "assets/app_icon/app_icon_1024.png"

let size = NSSize(width: 1024, height: 1024)
let greenTop = NSColor(calibratedRed: 0.22, green: 0.78, blue: 0.48, alpha: 1)
let greenBottom = NSColor(calibratedRed: 0.03, green: 0.47, blue: 0.39, alpha: 1)
let ivory = NSColor(calibratedRed: 0.98, green: 0.95, blue: 0.85, alpha: 1)

guard let context = CGContext(
  data: nil,
  width: Int(size.width),
  height: Int(size.height),
  bitsPerComponent: 8,
  bytesPerRow: Int(size.width) * 4,
  space: CGColorSpaceCreateDeviceRGB(),
  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
) else {
  fputs("Failed to create icon drawing context\n", stderr)
  exit(1)
}
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)

NSGradient(starting: greenTop, ending: greenBottom)?
  .draw(in: NSRect(origin: .zero, size: size), angle: 90)

let fontURL = URL(fileURLWithPath: "assets/fonts/AmiriQuran.ttf")
guard CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil),
  let font = NSFont(name: "AmiriQuran-Regular", size: 390)
else {
  fputs("Failed to load the bundled Amiri calligraphy font\n", stderr)
  exit(1)
}

let title = "إعراب" as NSString
let titleRect = NSRect(x: 48, y: 280, width: 928, height: 464)
let titleParagraph = NSMutableParagraphStyle()
titleParagraph.alignment = .center
titleParagraph.baseWritingDirection = .rightToLeft
let titleAttributes: [NSAttributedString.Key: Any] = [
  .font: font,
  .foregroundColor: ivory,
  .paragraphStyle: titleParagraph,
]
let titleBounds = title.boundingRect(
  with: titleRect.size,
  options: [.usesLineFragmentOrigin, .usesFontLeading],
  attributes: titleAttributes
)
let centeredTitleRect = NSRect(
  x: titleRect.minX,
  y: titleRect.minY + ((titleRect.height - titleBounds.height) / 2),
  width: titleRect.width,
  height: titleBounds.height
)
title.draw(in: centeredTitleRect, withAttributes: titleAttributes)

NSGraphicsContext.restoreGraphicsState()

guard
  let renderedImage = context.makeImage(),
  let bitmap = Optional(NSBitmapImageRep(cgImage: renderedImage)),
  let pngData = bitmap.representation(using: .png, properties: [:])
else {
  fputs("Failed to render icon\n", stderr)
  exit(1)
}

try pngData.write(to: URL(fileURLWithPath: outputPath))
print("Wrote \(outputPath)")
