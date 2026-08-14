import AppKit

let outputPath = CommandLine.arguments.count > 1
  ? CommandLine.arguments[1]
  : "assets/app_icon/app_icon_1024.png"

let size = NSSize(width: 1024, height: 1024)
let blueTop = NSColor(calibratedRed: 0.12, green: 0.43, blue: 0.89, alpha: 1)
let blueBottom = NSColor(calibratedRed: 0.04, green: 0.20, blue: 0.42, alpha: 1)
let sunshine = NSColor(calibratedRed: 0.96, green: 0.71, blue: 0.06, alpha: 1)
let coral = NSColor(calibratedRed: 0.91, green: 0.36, blue: 0.29, alpha: 1)
let paper = NSColor(calibratedRed: 1, green: 0.98, blue: 0.92, alpha: 1)

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

NSGradient(starting: blueTop, ending: blueBottom)?
  .draw(in: NSRect(origin: .zero, size: size), angle: 90)

let sunPath = NSBezierPath(ovalIn: NSRect(x: 714, y: 716, width: 190, height: 190))
sunshine.setFill()
sunPath.fill()

let shadow = NSShadow()
shadow.shadowBlurRadius = 28
shadow.shadowOffset = NSSize(width: 0, height: -14)
shadow.shadowColor = NSColor(calibratedWhite: 0, alpha: 0.22)
NSGraphicsContext.saveGraphicsState()
shadow.set()
let card = NSBezierPath(
  roundedRect: NSRect(x: 126, y: 154, width: 772, height: 700),
  xRadius: 96,
  yRadius: 96
)
paper.setFill()
card.fill()
NSGraphicsContext.restoreGraphicsState()

let accent = NSBezierPath(
  roundedRect: NSRect(x: 238, y: 264, width: 548, height: 34),
  xRadius: 17,
  yRadius: 17
)
coral.setFill()
accent.fill()

let paragraph = NSMutableParagraphStyle()
paragraph.alignment = .center
paragraph.baseWritingDirection = .rightToLeft

let title = "إعراب" as NSString
let titleRect = NSRect(x: 172, y: 380, width: 680, height: 260)
let fontNames = ["Diwan Kufi", "DecoType Naskh", "Geeza Pro", "Al Bayan", "SF Arabic"]
let font = fontNames.compactMap { NSFont(name: $0, size: 178) }.first
  ?? NSFont.systemFont(ofSize: 178, weight: .bold)
let textAttributes: [NSAttributedString.Key: Any] = [
  .font: font,
  .foregroundColor: blueBottom,
  .paragraphStyle: paragraph,
]
let titleBounds = title.boundingRect(
  with: titleRect.size,
  options: [.usesLineFragmentOrigin, .usesFontLeading],
  attributes: textAttributes
)
let centeredTitleRect = NSRect(
  x: titleRect.minX,
  y: titleRect.minY + ((titleRect.height - titleBounds.height) / 2),
  width: titleRect.width,
  height: titleBounds.height
)
title.draw(in: centeredTitleRect, withAttributes: textAttributes)

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
