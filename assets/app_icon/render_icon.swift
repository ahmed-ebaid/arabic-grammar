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
let greenTop = NSColor(calibratedRed: 0.22, green: 0.78, blue: 0.48, alpha: 1)
let greenBottom = NSColor(calibratedRed: 0.03, green: 0.47, blue: 0.39, alpha: 1)
let ivory = NSColor(calibratedRed: 0.98, green: 0.95, blue: 0.85, alpha: 1)

// Adaptive launcher layers are masked and the generated adaptive-icon XML
// already insets them by 16% (drawable -> 68% of the canvas). Budget the
// word against that: 820/1024 of the drawable lands at ~82% of the visible
// 72dp viewport, inside the 66dp keyline circle on every mask shape.
let isAdaptiveLayer = isForeground || isMonochrome
let maxTitleWidth: CGFloat = isAdaptiveLayer ? 820 : 800
let maxTitleHeight: CGFloat = isAdaptiveLayer ? 390 : 340

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
  NSGradient(starting: greenTop, ending: greenBottom)?
    .draw(in: NSRect(origin: .zero, size: size), angle: 90)
}

let fontURL = URL(fileURLWithPath: "assets/fonts/AmiriQuran.ttf")
guard CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil) else {
  fputs("Failed to load the bundled Amiri calligraphy font\n", stderr)
  exit(1)
}

let titleColor = isMonochrome ? NSColor.white : ivory

func makeTitleLine(pointSize: CGFloat) -> CTLine? {
  guard let font = NSFont(name: "AmiriQuran-Regular", size: pointSize) else { return nil }
  let paragraph = NSMutableParagraphStyle()
  paragraph.alignment = .center
  paragraph.baseWritingDirection = .rightToLeft
  let attributes: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: titleColor,
    NSAttributedString.Key(kCTForegroundColorAttributeName as String): titleColor.cgColor,
    .paragraphStyle: paragraph,
  ]
  return CTLineCreateWithAttributedString(
    NSAttributedString(string: "إعراب", attributes: attributes)
  )
}

// Measure the real glyph outlines. Line-fragment metrics bundle in leading
// that pushes the word off-centre and lets it overflow the adaptive mask.
let probeSize: CGFloat = 512
guard let probeLine = makeTitleLine(pointSize: probeSize) else {
  fputs("Failed to load the bundled Amiri calligraphy font\n", stderr)
  exit(1)
}
let probeBounds = CTLineGetBoundsWithOptions(probeLine, [.useGlyphPathBounds])
let titleScale = min(
  maxTitleWidth / probeBounds.width,
  maxTitleHeight / probeBounds.height
)

if !isBackground {
  guard let titleLine = makeTitleLine(pointSize: probeSize * titleScale) else {
    fputs("Failed to load the bundled Amiri calligraphy font\n", stderr)
    exit(1)
  }
  let titleBounds = CTLineGetBoundsWithOptions(titleLine, [.useGlyphPathBounds])
  context.textMatrix = .identity
  context.textPosition = CGPoint(
    x: (size.width / 2) - titleBounds.midX,
    y: (size.height / 2) - titleBounds.midY
  )
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
