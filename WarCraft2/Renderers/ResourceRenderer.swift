//
//  ResourceRenderer.swift
//  WarCraft2
//
//  Created by Andrew Cope on 11/4/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Cocoa

enum EMiniIconTypes: Int {
    case Gold
    case Lumber
    case Food
}

class CResourceRenderer: NSObject {

    var DIconTileset: CGraphicTileset = CGraphicTileset()
    var DFont: CFontTileset = CFontTileset()
    var DPlayer: CPlayerData?
    var DIconIndices = [Int]()
    var DTextHeight = 5
    var DForegroundColor = NSColor.white
    var DBackgroundColor = NSColor.black
    var DInsufficientColor = NSColor.red
    var DLastGoldDisplay = 0
    var DLastLumberDisplay = 0

    override init() {
        DIconIndices = [
            DIconTileset.FindTile(tilename: "gold"),
            DIconTileset.FindTile(tilename: "lumber"),
            DIconTileset.FindTile(tilename: "food"),
        ]
    }

    func DrawResources(surface: CGraphicSurface) {
        if let DPlayer = DPlayer {
            var Width = 0
            var Height = 0
            var TextYOffset = 0
            var ImageYOffset = 0
            var WidthSeparation = 0
            var XOffset = 0

            var DeltaGold = DPlayer.DGold - DLastGoldDisplay
            var DeltaLumber = DPlayer.DLumber - DLastLumberDisplay

            DeltaGold /= 5
            if (-3 < DeltaGold) && (3 > DeltaGold) {
                DLastGoldDisplay = DPlayer.DGold
            } else {
                DLastGoldDisplay = DPlayer.DGold
            }

            DeltaLumber /= 5
            if (-3 < DeltaLumber) && (3 > DeltaLumber) {
                DLastLumberDisplay = DPlayer.DLumber
            } else {
                DLastLumberDisplay += DeltaLumber
            }

            Width = surface.Width()
            Height = surface.Height()
            TextYOffset = Height / 2 - DTextHeight / 2
            ImageYOffset = Height / 2 - DIconTileset.TileHeight() / 2
            WidthSeparation = Width / 4
            XOffset = Width / 8

            if DPlayer.FoodConsumption() > DPlayer.FoodProduction() {
                var secondTextWidth = 0
                var TotalTextWidth = 0
                var TextHeight = 0
            } else {
            }
        }
    }
}
