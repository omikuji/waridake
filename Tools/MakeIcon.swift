#!/usr/bin/env swift
// Draws the Waridake app icon and writes Resources/Waridake.icns.
//   swift Tools/MakeIcon.swift   (invoked by `make icon`)
// A katana, laid across a plate that its cut has parted in two.

import AppKit

let canvas: CGFloat = 1024

// MARK: - Colors

func rgb(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: a)
}

let inkTop = rgb(38, 54, 62)
let inkBottom = rgb(16, 24, 30)
let steelDark = rgb(138, 152, 164)
let steelMid = rgb(226, 233, 240)
let steelLight = rgb(252, 253, 255)
let hamonColor = rgb(255, 255, 255, 0.85)
let handleColor = rgb(46, 34, 30)
let wrapColor = rgb(206, 190, 160)
let brassColor = rgb(198, 158, 78)

// MARK: - Helpers

func gradient(_ colors: [CGColor], _ locations: [CGFloat]) -> CGGradient {
    CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: colors as CFArray, locations: locations)!
}

/// Clips drawing to one side of the line through `point` at `angle`
func clipHalfPlane(_ ctx: CGContext, through point: CGPoint, angle: CGFloat, above: Bool) {
    ctx.saveGState()
    let path = CGMutablePath()
    let big: CGFloat = canvas * 3
    let transform = CGAffineTransform(translationX: point.x, y: point.y).rotated(by: angle)
    path.addRect(
        CGRect(x: -big, y: above ? 0 : -big, width: big * 2, height: big), transform: transform)
    ctx.addPath(path)
    ctx.clip()
}

// MARK: - Sword

let swordAngle: CGFloat = 32 * .pi / 180
let bladeStart: CGFloat = -150   // where the guard sits
let bladeTip: CGFloat = 470
let hiltEnd: CGFloat = -400
let bladeHalf: CGFloat = 22
let sori: CGFloat = 34           // curvature of the blade

/// The blade outline, in the sword's own coordinates
func bladePath() -> CGMutablePath {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: bladeStart, y: -bladeHalf))
    path.addCurve(
        to: CGPoint(x: bladeTip, y: 6),
        control1: CGPoint(x: bladeTip * 0.45, y: -bladeHalf - sori * 0.7),
        control2: CGPoint(x: bladeTip * 0.85, y: -bladeHalf - sori * 0.25))
    path.addCurve(
        to: CGPoint(x: bladeStart, y: bladeHalf),
        control1: CGPoint(x: bladeTip * 0.85, y: bladeHalf - sori * 0.55),
        control2: CGPoint(x: bladeTip * 0.45, y: bladeHalf - sori * 0.45))
    path.closeSubpath()
    return path
}

func drawSword(_ ctx: CGContext) {
    ctx.saveGState()
    ctx.translateBy(x: 512, y: 512)
    ctx.rotate(by: swordAngle)

    // Blade, shaded from the spine down to the edge
    ctx.saveGState()
    ctx.addPath(bladePath())
    ctx.clip()
    ctx.drawLinearGradient(
        gradient([steelDark, steelMid, steelLight, steelMid], [0, 0.35, 0.62, 1]),
        start: CGPoint(x: 0, y: -bladeHalf - sori),
        end: CGPoint(x: 0, y: bladeHalf), options: [])

    // Hamon: the temper line that follows the cutting edge
    ctx.setStrokeColor(hamonColor)
    ctx.setLineWidth(7)
    let hamon = CGMutablePath()
    hamon.move(to: CGPoint(x: bladeStart + 20, y: -bladeHalf + 11))
    hamon.addCurve(
        to: CGPoint(x: bladeTip - 30, y: 2),
        control1: CGPoint(x: bladeTip * 0.45, y: -bladeHalf - sori * 0.7 + 13),
        control2: CGPoint(x: bladeTip * 0.85, y: -bladeHalf - sori * 0.25 + 11))
    ctx.addPath(hamon)
    ctx.strokePath()
    ctx.restoreGState()

    // Tsuba, seen edge-on: a bar across the blade rather than a disc
    ctx.setFillColor(brassColor)
    ctx.addPath(CGPath(
        roundedRect: CGRect(x: bladeStart - 20, y: -66, width: 30, height: 132),
        cornerWidth: 12, cornerHeight: 12, transform: nil))
    ctx.fillPath()
    ctx.setFillColor(rgb(150, 116, 52, 0.7))
    ctx.fill(CGRect(x: bladeStart - 20, y: -66, width: 8, height: 132))

    // Tsuka
    let hilt = CGPath(
        roundedRect: CGRect(x: hiltEnd, y: -26, width: bladeStart - hiltEnd - 26, height: 52),
        cornerWidth: 22, cornerHeight: 22, transform: nil)
    ctx.setFillColor(handleColor)
    ctx.addPath(hilt)
    ctx.fillPath()

    // Wrap, clipped to the hilt so it does not spill over
    ctx.saveGState()
    ctx.addPath(hilt)
    ctx.clip()
    ctx.setStrokeColor(wrapColor)
    ctx.setLineWidth(9)
    for step in 0..<7 {
        let x = hiltEnd - 10 + CGFloat(step) * 34
        ctx.move(to: CGPoint(x: x, y: -30))
        ctx.addLine(to: CGPoint(x: x + 30, y: 30))
        ctx.move(to: CGPoint(x: x + 30, y: -30))
        ctx.addLine(to: CGPoint(x: x, y: 30))
    }
    ctx.strokePath()
    ctx.restoreGState()

    ctx.restoreGState()
}

// MARK: - The whole icon

func drawIcon(_ ctx: CGContext) {
    ctx.setShouldAntialias(true)
    ctx.interpolationQuality = .high

    let plate = CGRect(x: 100, y: 100, width: 824, height: 824)
    ctx.saveGState()
    ctx.addPath(CGPath(roundedRect: plate, cornerWidth: 185, cornerHeight: 185, transform: nil))
    ctx.clip()
    ctx.drawLinearGradient(
        gradient([inkTop, inkBottom], [0, 1]),
        start: CGPoint(x: 0, y: canvas), end: CGPoint(x: 0, y: 0), options: [])

    // The plate is parted along the path of the cut. Barely there, but it is
    // what the app does: one clean line, two halves.
    let cut = CGPoint(x: 512, y: 512)
    clipHalfPlane(ctx, through: cut, angle: swordAngle, above: true)
    ctx.setFillColor(rgb(255, 255, 255, 0.05))
    ctx.fill(CGRect(x: 0, y: 0, width: canvas, height: canvas))
    ctx.restoreGState()

    ctx.setStrokeColor(rgb(255, 255, 255, 0.12))
    ctx.setLineWidth(3)
    ctx.move(to: CGPoint(x: cut.x - 700 * cos(swordAngle), y: cut.y - 700 * sin(swordAngle)))
    ctx.addLine(to: CGPoint(x: cut.x + 700 * cos(swordAngle), y: cut.y + 700 * sin(swordAngle)))
    ctx.strokePath()

    drawSword(ctx)
    ctx.restoreGState()
}

// MARK: - Output

func render() -> CGImage {
    let ctx = CGContext(
        data: nil, width: Int(canvas), height: Int(canvas),
        bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    drawIcon(ctx)
    return ctx.makeImage()!
}

func scaled(_ image: CGImage, to size: Int) -> CGImage {
    let ctx = CGContext(
        data: nil, width: size, height: size,
        bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.interpolationQuality = .high
    ctx.draw(image, in: CGRect(x: 0, y: 0, width: size, height: size))
    return ctx.makeImage()!
}

func writePNG(_ image: CGImage, to url: URL) throws {
    let rep = NSBitmapImageRep(cgImage: image)
    guard let data = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "MakeIcon", code: 1)
    }
    try data.write(to: url)
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconset = root.appendingPathComponent("build/Waridake.iconset")
try? FileManager.default.removeItem(at: iconset)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

let master = render()
try writePNG(master, to: root.appendingPathComponent("build/icon-preview.png"))

for size in [16, 32, 128, 256, 512] {
    try writePNG(scaled(master, to: size), to: iconset.appendingPathComponent("icon_\(size)x\(size).png"))
    try writePNG(scaled(master, to: size * 2), to: iconset.appendingPathComponent("icon_\(size)x\(size)@2x.png"))
}

print("==> \(iconset.path)")
