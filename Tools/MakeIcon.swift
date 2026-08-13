#!/usr/bin/env swift
// Draws the Waridake app icon and writes Resources/Waridake.icns.
//   swift Tools/MakeIcon.swift   (invoked by `make icon`)
// A stalk of bamboo being split by a katana — waridake means "split bamboo".

import AppKit

let canvas: CGFloat = 1024

// MARK: - Colors

func rgb(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: a)
}

let inkTop = rgb(38, 54, 62)
let inkBottom = rgb(18, 26, 32)
let bambooDark = rgb(58, 110, 58)
let bambooMid = rgb(124, 186, 92)
let bambooLight = rgb(178, 214, 128)
let cutFace = rgb(238, 244, 214)
let steelDark = rgb(150, 162, 172)
let steelLight = rgb(248, 250, 252)
let handleColor = rgb(62, 44, 36)
let wrapColor = rgb(214, 198, 168)
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
    let transform = CGAffineTransform(translationX: point.x, y: point.y)
        .rotated(by: angle)
    let rect = CGRect(x: -big, y: above ? 0 : -big, width: big * 2, height: big)
    path.addRect(rect, transform: transform)
    ctx.addPath(path)
    ctx.clip()
}

// MARK: - Bamboo

let culmRect = CGRect(x: 356, y: 40, width: 228, height: 1000)
let nodeYs: [CGFloat] = [240, 520, 800]

/// One culm: a horizontal gradient to read as a cylinder, plus the nodes.
func drawCulm(_ ctx: CGContext) {
    ctx.saveGState()
    let body = CGPath(roundedRect: culmRect, cornerWidth: 40, cornerHeight: 40, transform: nil)
    ctx.addPath(body)
    ctx.clip()

    ctx.drawLinearGradient(
        gradient([bambooDark, bambooMid, bambooLight, bambooMid, bambooDark],
                 [0, 0.22, 0.42, 0.68, 1]),
        start: CGPoint(x: culmRect.minX, y: 0),
        end: CGPoint(x: culmRect.maxX, y: 0),
        options: [])

    // Nodes. Drawn as slightly raised bands so they read as bamboo.
    for y in nodeYs {
        ctx.setFillColor(rgb(46, 88, 46, 0.55))
        ctx.fill(CGRect(x: culmRect.minX, y: y, width: culmRect.width, height: 14))
        ctx.setFillColor(rgb(206, 232, 168, 0.7))
        ctx.fill(CGRect(x: culmRect.minX, y: y + 14, width: culmRect.width, height: 7))
    }

    // A vertical highlight for sheen
    ctx.setFillColor(rgb(226, 244, 186, 0.35))
    ctx.fill(CGRect(x: culmRect.minX + 52, y: culmRect.minY, width: 26, height: culmRect.height))
    ctx.restoreGState()
}

// MARK: - Sword

/// The blade, curved, with the tip to the upper right and the hilt lower left.
func drawSword(_ ctx: CGContext, angle: CGFloat) {
    ctx.saveGState()
    ctx.translateBy(x: 476, y: 496)
    ctx.rotate(by: angle)

    let bladeLength: CGFloat = 452
    let bladeStart: CGFloat = -120   // where the guard sits
    let width: CGFloat = 34
    let sori: CGFloat = 30           // curvature of the blade

    // Blade, shaded from spine to edge
    let blade = CGMutablePath()
    blade.move(to: CGPoint(x: bladeStart, y: -width / 2))
    blade.addQuadCurve(
        to: CGPoint(x: bladeLength, y: 8),
        control: CGPoint(x: bladeLength * 0.55, y: -width / 2 - sori))
    blade.addQuadCurve(
        to: CGPoint(x: bladeStart, y: width / 2),
        control: CGPoint(x: bladeLength * 0.55, y: width / 2 - sori))
    blade.closeSubpath()

    ctx.saveGState()
    ctx.addPath(blade)
    ctx.clip()
    ctx.drawLinearGradient(
        gradient([steelDark, steelLight, steelDark], [0, 0.45, 1]),
        start: CGPoint(x: 0, y: -width), end: CGPoint(x: 0, y: width), options: [])
    // A thin highlight along the edge, standing in for a hamon
    ctx.setStrokeColor(rgb(255, 255, 255, 0.9))
    ctx.setLineWidth(6)
    ctx.move(to: CGPoint(x: bladeStart, y: -width / 2 + 8))
    ctx.addQuadCurve(
        to: CGPoint(x: bladeLength - 20, y: 4),
        control: CGPoint(x: bladeLength * 0.55, y: -width / 2 - sori + 10))
    ctx.strokePath()
    ctx.restoreGState()

    // Tsuba (guard)
    ctx.setFillColor(brassColor)
    ctx.fillEllipse(in: CGRect(x: bladeStart - 18, y: -46, width: 26, height: 92))

    // Tsuka (hilt)
    ctx.setFillColor(handleColor)
    let handle = CGPath(
        roundedRect: CGRect(x: bladeStart - 210, y: -28, width: 196, height: 56),
        cornerWidth: 20, cornerHeight: 20, transform: nil)
    ctx.addPath(handle)
    ctx.fillPath()
    // Hilt wrap, clipped to the hilt so it does not spill over
    ctx.saveGState()
    ctx.addPath(handle)
    ctx.clip()
    ctx.setStrokeColor(wrapColor)
    ctx.setLineWidth(9)
    for i in 0..<6 {
        let x = bladeStart - 206 + CGFloat(i) * 34
        ctx.move(to: CGPoint(x: x, y: -30))
        ctx.addLine(to: CGPoint(x: x + 30, y: 30))
    }
    ctx.strokePath()
    ctx.restoreGState()

    ctx.restoreGState()
}

// MARK: - The whole icon

func drawIcon(_ ctx: CGContext) {
    ctx.setShouldAntialias(true)
    ctx.interpolationQuality = .high

    // Background plate
    let plate = CGRect(x: 100, y: 100, width: 824, height: 824)
    let plated = CGPath(roundedRect: plate, cornerWidth: 185, cornerHeight: 185, transform: nil)
    ctx.saveGState()
    ctx.addPath(plated)
    ctx.clip()
    ctx.drawLinearGradient(
        gradient([inkTop, inkBottom], [0, 1]),
        start: CGPoint(x: 0, y: canvas), end: CGPoint(x: 0, y: 0), options: [])

    // The diagonal cut. It splits the culm into an upper and a lower piece.
    let cutAngle: CGFloat = 22 * .pi / 180
    let cutPoint = CGPoint(x: 470, y: 545)

    // Lower piece
    clipHalfPlane(ctx, through: cutPoint, angle: cutAngle, above: false)
    drawCulm(ctx)
    // The cut face
    ctx.saveGState()
    ctx.addPath(CGPath(roundedRect: culmRect, cornerWidth: 40, cornerHeight: 40, transform: nil))
    ctx.clip()
    ctx.setStrokeColor(cutFace)
    ctx.setLineWidth(26)
    ctx.move(to: CGPoint(x: cutPoint.x - 400, y: cutPoint.y - 400 * tan(cutAngle)))
    ctx.addLine(to: CGPoint(x: cutPoint.x + 400, y: cutPoint.y + 400 * tan(cutAngle)))
    ctx.strokePath()
    ctx.restoreGState()
    ctx.restoreGState()

    // Upper piece. Offset and rotated, so it reads as just having been cut.
    ctx.saveGState()
    ctx.translateBy(x: 58, y: 26)
    ctx.rotate(by: 7 * .pi / 180)
    ctx.translateBy(x: -40, y: -70)
    clipHalfPlane(ctx, through: cutPoint, angle: cutAngle, above: true)
    drawCulm(ctx)
    ctx.saveGState()
    ctx.addPath(CGPath(roundedRect: culmRect, cornerWidth: 40, cornerHeight: 40, transform: nil))
    ctx.clip()
    ctx.setStrokeColor(cutFace)
    ctx.setLineWidth(26)
    ctx.move(to: CGPoint(x: cutPoint.x - 400, y: cutPoint.y - 400 * tan(cutAngle)))
    ctx.addLine(to: CGPoint(x: cutPoint.x + 400, y: cutPoint.y + 400 * tan(cutAngle)))
    ctx.strokePath()
    ctx.restoreGState()
    ctx.restoreGState()

    drawSword(ctx, angle: cutAngle)

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
