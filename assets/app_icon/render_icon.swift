import AppKit
import CoreText

let arguments = Array(CommandLine.arguments.dropFirst())
let isForeground = arguments.contains("--foreground")
let isBackground = arguments.contains("--background")
let isMonochrome = arguments.contains("--monochrome")
let layerCount = [isForeground, isBackground, isMonochrome].filter { $0 }.count
guard layerCount <= 1 else {
  fputs("Choose only one adaptive icon layer\n", stderr)
  exit(1)
}
let outputPath = arguments.first(where: { !$0.hasPrefix("--") })
  ?? "assets/app_icon/app_icon_1024.png"

let size = NSSize(width: 1024, height: 1024)
let gradientTop = NSColor(calibratedRed: 0.25, green: 0.56, blue: 0.77, alpha: 1)
let gradientBottom = NSColor(calibratedRed: 0.08, green: 0.32, blue: 0.59, alpha: 1)
let titleColor = NSColor.white
let titleCenter = CGPoint(x: size.width / 2, y: 494)
let maxTitleWidth: CGFloat = 836
let maxTitleHeight: CGFloat = 560
let shadow = NSShadow()
shadow.shadowBlurRadius = 18
shadow.shadowOffset = NSSize(width: 0, height: -10)
shadow.shadowColor = NSColor(calibratedWhite: 0, alpha: 0.16)

// Match the Tajweed app's Farah lettering, gradient background, and soft shadow.
// The Android adaptive-icon XML applies its existing 16% inset to the layers.

guard let context = CGContext(
  data: nil,
  width: Int(size.width),
  height: Int(size.height),
  bitsPerComponent: 8,
  bytesPerRow: Int(size.width) * 4,
  space: CGColorSpaceCreateDeviceRGB(),
  bitmapInfo: isForeground || isMonochrome
    ? CGImageAlphaInfo.premultipliedLast.rawValue
    : CGImageAlphaInfo.noneSkipLast.rawValue
) else {
  fputs("Failed to create icon drawing context\n", stderr)
  exit(1)
}
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)

if !isForeground && !isMonochrome {
  NSGradient(starting: gradientTop, ending: gradientBottom)?
    .draw(in: NSRect(origin: .zero, size: size), angle: 90)
}

let renderedTitleColor = isMonochrome ? NSColor.white : titleColor

func makeTitleLine(pointSize: CGFloat) -> CTLine? {
  guard let font = NSFont(name: "Farah", size: pointSize) else { return nil }
  let paragraph = NSMutableParagraphStyle()
  paragraph.alignment = .center
  paragraph.baseWritingDirection = .rightToLeft
  let attributes: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: renderedTitleColor,
    NSAttributedString.Key(kCTForegroundColorAttributeName as String): renderedTitleColor.cgColor,
    .paragraphStyle: paragraph,
  ]
  return CTLineCreateWithAttributedString(
    NSAttributedString(string: "إعراب", attributes: attributes)
  )
}

// Measure glyph outlines rather than font leading so the calligraphy stays
// visually centered and inside the adaptive icon's safe area.
let probeSize: CGFloat = 512
guard let probeLine = makeTitleLine(pointSize: probeSize) else {
  fputs("The Farah font is not available on this Mac\n", stderr)
  exit(1)
}
let probeBounds = CTLineGetBoundsWithOptions(probeLine, [.useGlyphPathBounds])
let titleScale = min(
  maxTitleWidth / probeBounds.width,
  maxTitleHeight / probeBounds.height
)

if !isBackground {
  guard let titleLine = makeTitleLine(pointSize: probeSize * titleScale) else {
    fputs("The Farah font is not available on this Mac\n", stderr)
    exit(1)
  }
  let titleBounds = CTLineGetBoundsWithOptions(titleLine, [.useGlyphPathBounds])
  context.textMatrix = .identity
  context.textPosition = CGPoint(
    x: titleCenter.x - titleBounds.midX,
    y: titleCenter.y - titleBounds.midY
  )
  if !isMonochrome {
    context.setShadow(
      offset: shadow.shadowOffset,
      blur: shadow.shadowBlurRadius,
      color: shadow.shadowColor?.cgColor
    )
  }
  CTLineDraw(titleLine, context)
}

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
