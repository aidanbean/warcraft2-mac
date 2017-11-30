//
//  FogRenderer.swift
//  WarCraft2
//
//  Created by Keshav Tirumurti on 10/21/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation
import SpriteKit
import CoreGraphics

class CFogRenderer {

    var DTileset: CGraphicTileset
    var DMap: CVisibilityMap
    var DNoneIndex: Int
    var DSeenIndex: Int
    var DPartialIndex: Int
    var DFogIndices: [Int]
    var DBlackIndices: [Int]

    init(tileset: CGraphicTileset, map: CVisibilityMap) {
        DTileset = tileset
        DMap = map
        DPartialIndex = DTileset.FindTile(tilename: "partial")
        DFogIndices = [Int]()
        DBlackIndices = [Int]()
        for Index in 0 ..< 0x100 {
            var hexIndex = String(Index, radix: 16, uppercase: true)
            if hexIndex.count == 1 {
                var temp = "0"
                temp.append(hexIndex)
                hexIndex = temp
            }
            DFogIndices.append(DTileset.FindTile(tilename: "pf-\(hexIndex)"))
            DBlackIndices.append(DTileset.FindTile(tilename: "pb-\(hexIndex)"))
        }
        DSeenIndex = DFogIndices[0x00]
        DNoneIndex = DBlackIndices[0x00]
    }

    //    func DrawMap(surface: SKScene, rect: SRectangle) {
    //        let TileWidth = DTileset.TileWidth()
    //        let TileHeight = DTileset.TileHeight()
    //        var YIndex = rect.DYPosition / TileHeight
    //
    //        for YPos in stride(from: -(rect.DYPosition % TileHeight), to: rect.DHeight, by: TileHeight) {
    //            var XIndex = rect.DXPosition / TileWidth
    //
    //            for XPos in stride(from: -(rect.DXPosition % TileWidth), to: rect.DWidth, by: TileWidth) {
    //                let TileType = DMap.TileType(xindex: XIndex, yindex: YIndex)
    //
    //                if TileType == .None {
    //                    DTileset.DrawTile(skscene: surface, xpos: XPos, ypos: applicationData.DGameModel.DActualMap.Height() - YPos, tileindex: DNoneIndex)
    //                    continue
    //                } else if TileType == .Visible {
    //                    continue
    //                }
    //
    //                if TileType == .Seen || TileType == .SeenPartial {
    //                    DTileset.DrawTile(skscene: surface, xpos: XPos, ypos: applicationData.DGameModel.DActualMap.Height() - YPos, tileindex: DSeenIndex)
    //                }
    //                if ETileVisibility.PartialPartial == TileType || ETileVisibility.Partial == TileType {
    //                    var VisibilityIndex = 0
    //                    var VisibilityMask = 0x1
    //
    //                    for YOff in -1 ..< 2 {
    //                        for XOff in -1 ..< 2 {
    //                            if YOff != 0 || XOff != 0 {
    //                                let VisTile = DMap.TileType(xindex: XIndex + XOff, yindex: YIndex + YOff)
    //
    //                                if VisTile == .Visible {
    //                                    VisibilityIndex = VisibilityIndex | VisibilityMask
    //                                }
    //
    //                                VisibilityMask <<= 1
    //                            }
    //                        }
    //                    }
    //                    DTileset.DrawTile(skscene: surface, xpos: XPos, ypos: applicationData.DGameModel.DActualMap.Height() - YPos, tileindex: DFogIndices[VisibilityIndex])
    //                }
    //
    //                if TileType == .PartialPartial || TileType == .SeenPartial {
    //                    var VisibilityIndex = 0
    //                    var VisibilityMask = 0x1
    //
    //                    for YOff in -1 ..< 2 {
    //                        for XOff in -1 ..< 2 {
    //                            if YOff != 0 || XOff != 0 {
    //                                let VisTile = DMap.TileType(xindex: XIndex + XOff, yindex: YIndex + YOff)
    //
    //                                if ETileVisibility.Visible == VisTile || ETileVisibility.Partial == VisTile || ETileVisibility.Seen == VisTile {
    //                                    VisibilityIndex = VisibilityIndex | VisibilityMask
    //                                }
    //                                VisibilityMask <<= 1
    //                            }
    //                        }
    //                    }
    //                    DTileset.DrawTile(skscene: surface, xpos: XPos, ypos: YPos, tileindex: DBlackIndices[VisibilityIndex])
    //                }
    //                XIndex += 1
    //            }
    //            YIndex += 1
    //        }
    //    }
    func DrawMap(surface: SKScene, rect: SRectangle) {
        let TileWidth = DTileset.TileWidth()
        let TileHeight = DTileset.TileHeight()

        var YIndex: Int = rect.DYPosition / TileHeight
        var XIndex: Int = rect.DXPosition / TileWidth
        var YPos: Int = -(rect.DYPosition % TileHeight)
        var XPos: Int = -(rect.DXPosition % TileWidth)

        while true {
            if YPos > rect.DHeight {
                break
            }
            while true {
                if XPos > rect.DWidth {
                    break
                }
                let TileType: ETileVisibility = DMap.TileType(xindex: XIndex, yindex: YIndex)

                if TileType == ETileVisibility.None {
                    DTileset.DrawTile(skscene: surface, xpos: XPos, ypos: applicationData.DGameModel.DActualMap.Height() - YPos, tileindex: DNoneIndex)
                }
                if TileType == ETileVisibility.Visible {
                    // Do nothing
                }
                if (TileType == ETileVisibility.Seen) || (TileType == ETileVisibility.SeenPartial) {
                    DTileset.DrawTile(skscene: surface, xpos: XPos, ypos: applicationData.DGameModel.DActualMap.Height() - YPos, tileindex: DSeenIndex)
                }
                if TileType == ETileVisibility.PartialPartial || TileType == ETileVisibility.Partial {
                    var VisibilityIndex: Int = 0
                    var VisibilityMask = 0x1

                    for YOff in -1 ... 1 {
                        for XOff in -1 ... 1 {
                            if (YOff != 0) || (XOff != 0) {
                                let VisTile: ETileVisibility = DMap.TileType(xindex: XIndex + XOff, yindex: YIndex + YOff)
                                if VisTile == ETileVisibility.Visible {
                                    VisibilityIndex = VisibilityIndex | VisibilityMask
                                }
                                VisibilityMask = VisibilityMask << 1
                            }
                        }
                    }

                    DTileset.DrawTile(skscene: surface, xpos: XPos, ypos: applicationData.DGameModel.DActualMap.Height() - YPos, tileindex: DFogIndices[VisibilityIndex])
                }
                if TileType == ETileVisibility.PartialPartial || TileType == ETileVisibility.SeenPartial {
                    var VisibilityIndex: Int = 0
                    var VisibilityMask: Int = 0x1

                    for YOff in -1 ... 1 {
                        for XOff in -1 ... 1 {
                            if YOff != 0 || XOff != 0 {
                                let VisTile: ETileVisibility = DMap.TileType(xindex: XIndex + XOff, yindex: YIndex + YOff)

                                if VisTile == ETileVisibility.Visible || VisTile == ETileVisibility.Partial || VisTile == ETileVisibility.Seen {
                                    VisibilityIndex = VisibilityIndex | VisibilityMask
                                }
                                VisibilityMask = VisibilityMask << 1
                            }
                        }
                    }

                    DTileset.DrawTile(skscene: surface, xpos: XPos, ypos: applicationData.DGameModel.DActualMap.Height() - YPos, tileindex: DBlackIndices[VisibilityIndex])
                }
                XIndex = XIndex + 1
                XPos += TileWidth
            } // inner loop
            XIndex = rect.DXPosition / TileWidth
            XPos = -(rect.DXPosition % TileWidth)
            YIndex = YIndex + 1
            YPos += TileHeight
        } // outer loop
    }

    func DrawMiniMap(ResourceContext: CGraphicResourceContext) {
        ResourceContext.SetLineWidth(width: 1)
        ResourceContext.SetLineCap(cap: CGLineCap.square)

        for YPos in 0 ..< DMap.Height() {
            var XPos: Int = 0
            while XPos < DMap.Width() {
                let TileType = DMap.TileType(xindex: XPos, yindex: YPos)
                let XAnchor: Int = XPos
                while (XPos < DMap.Width()) && (TileType == DMap.TileType(xindex: XPos, yindex: YPos)) {
                    XPos = XPos + 1
                }
                if TileType != ETileVisibility.Visible {
                    var ColorRGBA: UInt32 = 0x0000_0000
                    switch TileType {
                    case .None:
                        ColorRGBA = 0xFF00_0000
                    case .SeenPartial, .Seen:
                        ColorRGBA = 0xA800_0000
                    default:
                        ColorRGBA = 0x5400_0000
                    }

                    ResourceContext.SetSourceRGBA(rgba: ColorRGBA)
                    ResourceContext.MoveTo(xpos: XAnchor, ypos: YPos)
                    ResourceContext.LineTo(xpos: XPos - 1, ypos: YPos)
                    ResourceContext.Stroke()
                }
            }
        }
    }
}
