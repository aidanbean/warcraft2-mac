//
//  MapRenderer.swift
//  WarCraft2
//
//  Created by Alexander Soong on 10/9/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation
// TODO: COME BACK AFTER I DO CTERRAINMAP

// TODO: implement MapRenderer
protocol PMapRenderer {

    // TODO: uncomment after CGraphicTileset is implemented
    var DTileset: CGraphicTileset {get set}

    // TODO: uncomment after CTerrainMap is implemented
    var DMap: CTerrainMap {get set}
    var DTileIndices: [[[Int]]] { get set }
    var DPixelIndices: [Int] { get set }

    // initializer
    // TODO: uncomment after CGraphicTileset, CTerrainMap is implemented
    init(config: CDataSource, tileset: CGraphicTileset, map: CTerrainMap)

    // functions to be implemented in CMapRenderer
    func MapWidth() -> Int
    func MapHeight() -> Int
    func DetailedMapWidth() -> Int
    func DetailedMapHeight() -> Int

    // functions to be implemented in CMapRenderer
    func DrawMap(surface: CGraphicSurface, typesurface: CGraphicSurface, rect: SRectangle)
    func DrawMiniMap(surface: CGraphicSurface)
}


final class CMapRenderer : PMapRenderer{
    var DTileset: CGraphicTileset
    var DMap: CTerrainMap = CTerrainMap()
    var DTileIndices: [[[Int]]] = [[[Int]]()]
    var DPixelIndices: [Int] = [Int]()

    func resize<T>(array: inout [T], size: Int, defaultValue: T) {
        while array.count < size {
            array.append(defaultValue)
        }
        while array.count > size {
            array.removeLast()
        }
    }

//    // huge constructor
    init(config: CDataSource, tileset: CGraphicTileset, map: CTerrainMap) {
        var LineSource:CCommentSkipLineDataSource = CCommentSkipLineDataSource(source: config, commentchar: "#")
        var TempString: String = String()
        var ItemCount: Int = Int()

        var tileset: CGraphicTileset = CGraphicTileset()

        var map: CTerrainMap = CTerrainMap()

        resize(array: &DPixelIndices, size: CTerrainMap.ETileType.Max, defaultValue: ETileType.None)
        if !LineSource.Read(line: &TempString) {
            return
        }
        ItemCount = Int(TempString)!

        var Index: Int = 0
        repeat {
            var Tokens: [String] = [String]()
            if !LineSource.Read(line: &TempString) {
                return
            }
            let tokenizer: CTokenizer
            var tokens: [String]
            tokenizer.Tokenize(tokens: &tokens, data: TempString)//, delimiters: TempString)
            
//            Richard, I’m assuming you already tried `var uint = char as! UInt8` (edited)
//            var ColorValue: uint32 = tokens.first as! uint32
            var ColorValue: uint32 = uint32(tokens.first!)!
            var PixelIndex: Int = 0
            
            if(tokens.first == "light-grass"){
                PixelIndex = CTerrainMap.ETileType.LightGrass.rawValue
            }
            else if(tokens.first == "dark-grass"){
                PixelIndex = CTerrainMap.ETileType.DarkGrass.rawValue
            }
            else if(tokens.first == "light-dirt"){
                PixelIndex = CTerrainMap.ETileType.LightDirt.rawValue
            }
            else if(tokens.first == "dark-dirt"){
                PixelIndex = CTerrainMap.ETileType.DarkDirt.rawValue
            }
            else if(tokens.first == "rock"){
                PixelIndex = CTerrainMap.ETileType.Rock.rawValue
            }
            else if(tokens.first == "forest"){
                PixelIndex = CTerrainMap.ETileType.Forest.rawValue
            }
            else if(tokens.first == "stump"){
                PixelIndex = CTerrainMap.ETileType.Stump.rawValue
            }
            else if(tokens.first == "shallow-water"){
                PixelIndex = CTerrainMap.ETileType.ShallowWater.rawValue
            }
            else if(tokens.first == "deep-water"){
                PixelIndex = CTerrainMap.ETileType.DeepWater.rawValue
            }
            else{
                PixelIndex = CTerrainMap.ETileType.Rubble.rawValue
            }
            DPixelIndices[PixelIndex] = Int(ColorValue)
            
            
            
            Index += 1
        } while Index < ItemCount


    }


    func MapWidth() -> Int {
        return DMap.Width()
    }

    func MapHeight() -> Int {
        return DMap.Height()
    }

    func DetailedMapWidth() -> Int {
        return DMap.Width() * DTileset.TileWidth()
    }

    func DetailedMapHeight() -> Int {
        return DMap.Height() * DTileset.TileHeight()
    }

    func DrawMap(surface: CGraphicSurface, typesurface: CGraphicSurface, rect: SRectangle) {
        var TileWidth: Int = Int()
        var TileHeight: Int = Int()
        
        TileWidth = DTileset.TileWidth()
        TileHeight = DTileset.TileHeight()
        
        typesurface.Clear(xpos: Int(nil), ypos: Int(nil), width: Int(nil), height: Int(nil))
        
        var YIndex: Int = rect.DYPosition / TileHeight
        var YPos: Int = -(rect.DYPosition % TileHeight)
        var XIndex: Int = rect.DXPosition / TileWidth
        var XPos: Int = -(rect.DXPosition % TileWidth)
        repeat {
            repeat {
                var PixelType: CPixelType = CPixelType(DMap.TileType(XIndex, YIndex))
                var ThisTileType:ETileType = DMap.TileType(XIndex, YIndex)
                var TileIndex: Int = self.DMap.TileType
                
                
                
                
                XIndex += 1
                YPos += TileWidth
            } while XPos < rect.DWidth
            
            YIndex += 1
            YPos += TileHeight
        } while YPos < rect.DHeight
        

    }

    func DrawMiniMap(surface: CGraphicSurface) {
        <#code#>
    }

 }

