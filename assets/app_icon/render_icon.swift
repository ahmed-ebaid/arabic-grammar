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
let theme: String = {
  if let flag = arguments.first(where: { $0.hasPrefix("--theme=") }) {
    return String(flag.dropFirst("--theme=".count))
  }
  return "default"
}()
guard ["default", "ramadan", "eid_al_fitr", "eid_al_adha"].contains(theme) else {
  fputs("Unknown theme '\(theme)'. Use default, ramadan, eid_al_fitr or eid_al_adha.\n", stderr)
  exit(1)
}
let outputPath = arguments.first(where: { !$0.hasPrefix("--") })
  ?? "assets/app_icon/app_icon_1024.png"

let size = NSSize(width: 1024, height: 1024)
let gold = NSColor(calibratedRed: 0.98, green: 0.80, blue: 0.36, alpha: 1.0)
let (gradientTop, gradientBottom): (NSColor, NSColor) = {
  switch theme {
  case "ramadan":
    return (
      NSColor(calibratedRed: 0.08, green: 0.32, blue: 0.56, alpha: 1),
      NSColor(calibratedRed: 0.03, green: 0.12, blue: 0.30, alpha: 1)
    )
  case "eid_al_adha":
    return (
      NSColor(calibratedRed: 0.14, green: 0.45, blue: 0.72, alpha: 1),
      NSColor(calibratedRed: 0.05, green: 0.22, blue: 0.48, alpha: 1)
    )
  default:
    return (
      NSColor(calibratedRed: 0.25, green: 0.56, blue: 0.77, alpha: 1),
      NSColor(calibratedRed: 0.08, green: 0.32, blue: 0.59, alpha: 1)
    )
  }
}()
let titleColor = NSColor.white
let titleCenter = CGPoint(x: size.width / 2, y: 494)
let maxTitleWidth: CGFloat = 836
let maxTitleHeight: CGFloat = 560
let shadow = NSShadow()
shadow.shadowBlurRadius = 18
shadow.shadowOffset = NSSize(width: 0, height: -10)
shadow.shadowColor = NSColor(calibratedWhite: 0, alpha: 0.16)

func drawStar(center: NSPoint, outerRadius: CGFloat, color: NSColor) {
  let innerRadius = outerRadius * 0.42
  let path = NSBezierPath()
  for index in 0..<10 {
    let radius = index.isMultiple(of: 2) ? outerRadius : innerRadius
    let angle = CGFloat.pi / 2 + CGFloat(index) * CGFloat.pi / 5
    let point = NSPoint(
      x: center.x + cos(angle) * radius,
      y: center.y + sin(angle) * radius
    )
    if index == 0 { path.move(to: point) } else { path.line(to: point) }
  }
  path.close()
  color.setFill()
  path.fill()
}

func drawCrescent(center: NSPoint, radius: CGFloat, color: NSColor) {
  let outer = NSBezierPath(
    ovalIn: NSRect(
      x: center.x - radius, y: center.y - radius,
      width: radius * 2, height: radius * 2
    )
  )
  let cutRadius = radius * 0.82
  let cutCenter = NSPoint(x: center.x + radius * 0.38, y: center.y + radius * 0.18)
  let cut = NSBezierPath(
    ovalIn: NSRect(
      x: cutCenter.x - cutRadius, y: cutCenter.y - cutRadius,
      width: cutRadius * 2, height: cutRadius * 2
    )
  )
  NSGraphicsContext.saveGraphicsState()
  outer.addClip()
  let crescent = NSBezierPath(rect: outer.bounds)
  crescent.append(cut)
  crescent.windingRule = .evenOdd
  color.setFill()
  crescent.fill()
  NSGraphicsContext.restoreGraphicsState()
}

func drawSeasonalDecoration() {
  switch theme {
  case "ramadan":
    drawCrescent(center: NSPoint(x: 806, y: 872), radius: 86, color: gold)
    drawStar(center: NSPoint(x: 882, y: 900), outerRadius: 22, color: gold)
    for (x, y, r) in [(170.0, 900.0, 14.0), (290.0, 948.0, 9.0), (420.0, 890.0, 11.0), (120.0, 140.0, 9.0), (900.0, 150.0, 12.0)] {
      drawStar(center: NSPoint(x: x, y: y), outerRadius: r, color: gold.withAlphaComponent(0.85))
    }
  case "eid_al_fitr":
    drawCrescent(center: NSPoint(x: 806, y: 872), radius: 80, color: gold)
    for (x, y, r) in [(882.0, 904.0, 22.0), (180.0, 890.0, 24.0), (310.0, 944.0, 14.0), (140.0, 140.0, 16.0), (884.0, 140.0, 16.0)] {
      drawStar(center: NSPoint(x: x, y: y), outerRadius: r, color: gold)
    }
  case "eid_al_adha":
    let border = NSBezierPath(
      roundedRect: NSRect(x: 40, y: 40, width: 944, height: 944),
      xRadius: 200, yRadius: 200
    )
    border.lineWidth = 18
    gold.withAlphaComponent(0.9).setStroke()
    border.stroke()
    drawCrescent(center: NSPoint(x: 512, y: 872), radius: 70, color: gold)
    drawStar(center: NSPoint(x: 578, y: 896), outerRadius: 18, color: gold)
  default:
    break
  }
}

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
  if theme != "default" {
    drawSeasonalDecoration()
  }
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
