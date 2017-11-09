//
//  GraphicMulticolorTileset.swift
//  WarCraft2
//
//  Created by Aidan Bean on 10/18/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

class CGraphicMulticolorTileset: CGraphicTileset {
    var DColoredTilesets: [CGraphicSurface]
    var DColorMap: CGraphicRecolorMap

    override init() {
        DColoredTilesets = []
        DColorMap = CGraphicRecolorMap()
        super.init()
    }

    deinit {}

    func TestLoadTileset(colormap: CGraphicRecolorMap, source: CDataSource, assetName: String) -> Bool {

        if !super.TestLoadTileset(source: source, assetName: assetName) {
            return false
        }
        DColoredTilesets.removeAll()
        DColoredTilesets.append(DSurfaceTileset!)
        for ColIndex in 1 ..< colormap.GroupCount() {
            DColoredTilesets.append(colormap.RecolorSurface(index: ColIndex, srcsurface: DSurfaceTileset!)!)
        }
        return true
    }

    func LoadTileset(colormap: CGraphicRecolorMap, source: CDataSource) -> Bool {
        DColorMap = colormap
        if !super.LoadTileset(source: source) {
            return false
        }
        DColoredTilesets.removeAll()
        DColoredTilesets.append(DSurfaceTileset!)
        for ColIndex in 1 ..< colormap.GroupCount() {
            DColoredTilesets.append(colormap.RecolorSurface(index: ColIndex, srcsurface: DSurfaceTileset!)!)
        }
        return true
    }

    func DrawTile(surface: CGraphicSurface, xpos: Int, ypos: Int, tileindex: Int, colorindex: Int) {
        if (0 > tileindex) || (tileindex >= DTileCount) {
            return
        }
        if (0 > colorindex) || (colorindex >= DColoredTilesets.count) {
            return
        }

        surface.Draw(srcsurface: DColoredTilesets[colorindex], dxpos: xpos, dypos: ypos, width: DTileWidth, height: DTileHeight, sxpos: 0, sypos: tileindex * DTileHeight)
    }
}
