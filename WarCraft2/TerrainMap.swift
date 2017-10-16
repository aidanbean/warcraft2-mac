//
//  TerrainMap.swift
//  WarCraft2
//
//  Created by Aidan Bean on 10/9/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation

class CTerrainMap {

    enum ETerrainTileType: Int {
        case None = 0
        case DarkGrass
        case LightGrass
        case DarkDirt
        case LightDirt
        case Rock
        case RockPartial
        case Forest
        case ForestPartial
        case DeepWater
        case ShallowWater
        case Max
    }

    enum ETileType: Int {
        case None = 0
        case DarkGrass
        case LightGrass
        case DarkDirt
        case LightDirt
        case Rock
        case Rubble
        case Forest
        case Stump
        case DeepWater
        case ShallowWater
        case Max
    }

    static let DInvalidPartial: UInt8 = UInt8()

    //  "protected:"
    static var DAllowedAdjacent: [[Bool]] =
        [
            [true, true, true, true, true, true, true, true, true, true, true],
            [true, true, true, false, false, false, false, false, false, false, false],
            [true, true, true, false, true, false, false, true, true, false, false],
            [true, false, false, true, true, false, false, false, false, false, false],
            [true, false, true, true, true, true, true, false, false, false, true],
            [true, false, false, false, true, true, true, false, false, false, false],
            [true, false, false, false, true, true, true, false, false, false, false],
            [true, false, true, false, false, false, false, true, true, false, false],
            [true, false, true, false, false, false, false, true, true, false, false],
            [true, false, false, false, false, false, false, false, false, true, true],
            [true, false, false, false, true, false, false, false, false, true, true],
        ]

    internal var DTerrainMap = [[ETerrainTileType]]()
    internal var DPartials = [[UInt8]]()
    internal var DMap = [[ETileType]]()
    internal var DMapIndices = [[Int]]()
    internal var DMapName: String
    internal var DRendered: Bool

    init() {
        DMapName = "not rendered"
        DRendered = false
    }

    init(map: CTerrainMap) {
        DTerrainMap = map.DTerrainMap
        DPartials = map.DPartials
        DMapName = map.DMapName
        DMap = map.DMap
        DMapIndices = map.DMapIndices
        DRendered = map.DRendered
    }

    deinit {}

    // TODO: translate to swift
    //    static func =(lhs: CTilePosition, rhs: CTilePosition) -> Bool {
    //        return (lhs.DX == rhs.DX && lhs.DX == rhs.DX)
    //    }

    func MapName() -> String {
        return DMapName
    }

    func Width() -> Int {
        if !DTerrainMap.isEmpty {
            return DTerrainMap[0].count - 1
        }
        return 0
    }

    func Height() -> Int {
        return DTerrainMap.count - 1
    }

    func ChangeTerrainTilePartial(xindex: Int, yindex: Int, val: UInt8) {
        if (0 > yindex) || (0 > xindex) {
            return
        }
        if yindex >= DPartials.count {
            return
        }
        if xindex >= DPartials[0].count {
            return
        }
        DPartials[yindex][xindex] = val
        for yOff in 0 ..< 2 {
            for xOff in 0 ..< 2 {
                if DRendered {
                    var type = ETileType.None
                    var index: Int = 0
                    let xPos: Int = xindex + xOff
                    let yPos: Int = yindex + yOff
                    if (0 < xPos) && (0 < yPos) {
                        if (yPos + 1 < DMap.count) && (xPos + 1 < DMap[yPos].count) {
                            CalculateTileTypeAndIndex(x: xPos - 1, y: yPos - 1, type: &type, index: &index)
                            DMap[yPos][xPos] = type
                            DMapIndices[yPos][xPos] = index
                        }
                    }
                }
            }
        }
    }

    func IsTraversable(type: ETileType) -> Bool {
        switch type {
        case .None,
             .DarkGrass,
             .LightGrass,
             .DarkDirt,
             .LightDirt,
             .Rubble,
             .Stump:
            return true
        default:
            return false
        }
    }

    func CanPlaceOn(type: ETileType) -> Bool {
        switch type {
        case .DarkGrass,
             .LightGrass,
             .DarkDirt,
             .LightDirt,
             .Rubble,
             .Stump:
            return true
        default:
            return false
        }
    }

    func CalculateTileTypeAndIndex(x: Int, y: Int, type: inout ETileType, index: inout Int) {
        let UL = DTerrainMap[y][x]
        let UR = DTerrainMap[y][x + 1]
        let LL = DTerrainMap[y + 1][x]
        let LR = DTerrainMap[y + 1][x + 1]

        let Temp1 = ((DPartials[y][x] & 0x8) >> 3)
        let Temp2 = ((DPartials[y][x + 1] & 0x4) >> 1)
        let Temp3 = ((DPartials[y + 1][x] & 0x2) << 1)
        let Temp4 = ((DPartials[y + 1][x + 1] & 0x1) << 3)
        var TypeIndex: Int = Int(Temp1) | Int(Temp2) | Int(Temp3) | Int(Temp4)

        if (ETerrainTileType.DarkGrass == UL) || (ETerrainTileType.DarkGrass == UR) || (ETerrainTileType.DarkGrass == LL) || (ETerrainTileType.DarkGrass == LR) {
            TypeIndex &= (ETerrainTileType.DarkGrass == UL) ? 0xF : 0xE
            TypeIndex &= (ETerrainTileType.DarkGrass == UR) ? 0xF : 0xD
            TypeIndex &= (ETerrainTileType.DarkGrass == LL) ? 0xF : 0xB
            TypeIndex &= (ETerrainTileType.DarkGrass == LR) ? 0xF : 0x7
            type = ETileType.DarkGrass
            index = TypeIndex

        } else if (ETerrainTileType.DarkDirt == UL) || (ETerrainTileType.DarkDirt == UR) || (ETerrainTileType.DarkDirt == LL) || (ETerrainTileType.DarkDirt == LR) {
            TypeIndex &= (ETerrainTileType.DarkDirt == UL) ? 0xF : 0xE
            TypeIndex &= (ETerrainTileType.DarkDirt == UR) ? 0xF : 0xD
            TypeIndex &= (ETerrainTileType.DarkDirt == LL) ? 0xF : 0xB
            TypeIndex &= (ETerrainTileType.DarkDirt == LR) ? 0xF : 0x7
            type = ETileType.DarkDirt
            index = TypeIndex
        } else if (ETerrainTileType.DeepWater == UL) || (ETerrainTileType.DeepWater == UR) || (ETerrainTileType.DeepWater == LL) || (ETerrainTileType.DeepWater == LR) {
            TypeIndex &= (ETerrainTileType.DeepWater == UL) ? 0xF : 0xE
            TypeIndex &= (ETerrainTileType.DeepWater == UR) ? 0xF : 0xD
            TypeIndex &= (ETerrainTileType.DeepWater == LL) ? 0xF : 0xB
            TypeIndex &= (ETerrainTileType.DeepWater == LR) ? 0xF : 0x7
            type = ETileType.DeepWater
            index = TypeIndex
        } else if (ETerrainTileType.ShallowWater == UL) || (ETerrainTileType.ShallowWater == UR) || (ETerrainTileType.ShallowWater == LL) || (ETerrainTileType.ShallowWater == LR) {
            TypeIndex &= (ETerrainTileType.ShallowWater == UL) ? 0xF : 0xE
            TypeIndex &= (ETerrainTileType.ShallowWater == UR) ? 0xF : 0xD
            TypeIndex &= (ETerrainTileType.ShallowWater == LL) ? 0xF : 0xB
            TypeIndex &= (ETerrainTileType.ShallowWater == LR) ? 0xF : 0x7
            type = ETileType.ShallowWater
            index = TypeIndex
        } else if (ETerrainTileType.Rock == UL) || (ETerrainTileType.Rock == UR) || (ETerrainTileType.Rock == LL) || (ETerrainTileType.Rock == LR) {
            TypeIndex &= (ETerrainTileType.Rock == UL) ? 0xF : 0xE
            TypeIndex &= (ETerrainTileType.Rock == UR) ? 0xF : 0xD
            TypeIndex &= (ETerrainTileType.Rock == LL) ? 0xF : 0xB
            TypeIndex &= (ETerrainTileType.Rock == LR) ? 0xF : 0x7
            type = ETileType.Rock
            index = TypeIndex
        } else if (ETerrainTileType.Forest == UL) || (ETerrainTileType.Forest == UR) || (ETerrainTileType.Forest == LL) || (ETerrainTileType.Forest == LR) {
            TypeIndex &= (ETerrainTileType.Forest == UL) ? 0xF : 0xE
            TypeIndex &= (ETerrainTileType.Forest == UR) ? 0xF : 0xD
            TypeIndex &= (ETerrainTileType.Forest == LL) ? 0xF : 0xB
            TypeIndex &= (ETerrainTileType.Forest == LR) ? 0xF : 0x7
            if TypeIndex != 0 {
                type = ETileType.Forest
                index = TypeIndex
            } else {
                type = ETileType.Stump
                index = ((ETerrainTileType.Forest == UL) ? 0x1 : 0x0) | ((ETerrainTileType.Forest == UR) ? 0x2 : 0x0) | ((ETerrainTileType.Forest == LL) ? 0x4 : 0x0) | ((ETerrainTileType.Forest == LR) ? 0x8 : 0x0)
            }
        } else if (ETerrainTileType.LightDirt == UL) || (ETerrainTileType.LightDirt == UR) || (ETerrainTileType.LightDirt == LL) || (ETerrainTileType.LightDirt == LR) {
            TypeIndex &= (ETerrainTileType.LightDirt == UL) ? 0xF : 0xE
            TypeIndex &= (ETerrainTileType.LightDirt == UR) ? 0xF : 0xD
            TypeIndex &= (ETerrainTileType.LightDirt == LL) ? 0xF : 0xB
            TypeIndex &= (ETerrainTileType.LightDirt == LR) ? 0xF : 0x7
            type = ETileType.LightDirt
            index = TypeIndex
        } else {
            // Error?
            type = ETileType.LightGrass
            index = 0xF
        }
    }

    // https://stackoverflow.com/questions/42821473/in-swift-can-i-write-a-generic-function-to-resize-an-array
    // there is no default resize function in swift for lists
    func resize<T>(array: inout [T], size: Int, defaultValue: T) {
        while array.count < size {
            array.append(defaultValue)
        }
        while array.count > size {
            array.removeLast()
        }
    }

    func RenderTerrain() {
        resize(array: &DMap, size: DTerrainMap.count + 1, defaultValue: [ETileType.None])
        resize(array: &DMapIndices, size: DTerrainMap.count + 1, defaultValue: [0])
        for YPos in 0 ..< DMap.count {
            if (0 == YPos) || (DMap.count - 1 == YPos) {
                for _ in 0 ..< DTerrainMap[0].count + 1 {
                    DMap[YPos].append(ETileType.Rock)
                    DMapIndices[YPos].append(0xF)
                }
            } else {
                for XPos in 0 ..< DTerrainMap[YPos - 1].count + 1 {
                    if (0 == XPos) || (DTerrainMap[YPos - 1].count == XPos) {
                        DMap[YPos].append(ETileType.Rock)
                        DMapIndices[YPos].append(0xF)
                    } else {
                        var Type: ETileType = ETileType.None
                        var Index: Int = 0
                        CalculateTileTypeAndIndex(x: XPos - 1, y: YPos - 1, type: &Type, index: &Index)
                        DMap[YPos].append(Type)
                        DMapIndices[YPos].append(Index)
                    }
                }
            }
        }
        DRendered = true
    }

    func LoadMap(source: CDataSource) throws -> Bool {
        let LineSource = CCommentSkipLineDataSource(source: source, commentchar: "#")
        var TempString = String()
        var Tokens: [String] = [String]()
        var MapWidth: Int
        var MapHeight: Int
        var ReturnStatus: Bool = false

        DTerrainMap.removeAll()

        if !LineSource.Read(line: &DMapName) {
            return ReturnStatus
        }
        if !LineSource.Read(line: &TempString) {
            return ReturnStatus
        }
        // TODO: Uncomment when CTokenizer has been written
        // CTokenizer.Tokenize(Tokens, TempString)
        if 2 != Tokens.count {
            return ReturnStatus
        }
        do { // not too sure how to catch errors
            var StringMap = [String]()
            MapWidth = Int(Tokens[0])!
            MapHeight = Int(Tokens[1])!
            if (8 > MapWidth) || (8 > MapHeight) {
                return ReturnStatus
            }
            while StringMap.count < MapHeight + 1 {
                if !LineSource.Read(line: &TempString) {
                    return ReturnStatus
                }
                StringMap.append(TempString)
                if MapWidth + 1 > StringMap.last!.count {
                    return ReturnStatus
                }
            }
            if MapHeight + 1 > StringMap.count {
                return ReturnStatus
            }
            resize(array: &DTerrainMap, size: MapHeight + 1, defaultValue: [ETerrainTileType.None])

            for Index in 0 ..< DTerrainMap.count {
                resize(array: &DTerrainMap[Index], size: MapWidth + 1, defaultValue: ETerrainTileType.None)
                for Inner in 0 ..< MapWidth + 1 {
                    switch StringMap[Index] {
                    case "G": DTerrainMap[Index][Inner] = ETerrainTileType.DarkGrass
                        break
                    case "g": DTerrainMap[Index][Inner] = ETerrainTileType.LightGrass
                        break
                    case "D": DTerrainMap[Index][Inner] = ETerrainTileType.DarkDirt
                        break
                    case "d": DTerrainMap[Index][Inner] = ETerrainTileType.LightDirt
                        break
                    case "R": DTerrainMap[Index][Inner] = ETerrainTileType.Rock
                        break
                    case "r": DTerrainMap[Index][Inner] = ETerrainTileType.RockPartial
                        break
                    case "F": DTerrainMap[Index][Inner] = ETerrainTileType.Forest
                        break
                    case "f": DTerrainMap[Index][Inner] = ETerrainTileType.ForestPartial
                        break
                    case "W": DTerrainMap[Index][Inner] = ETerrainTileType.DeepWater
                        break
                    case "w": DTerrainMap[Index][Inner] = ETerrainTileType.ShallowWater
                        break
                    default: return ReturnStatus
                    }
                    //  if(Inner) { to do confused on this part?
                    if !CTerrainMap.DAllowedAdjacent[DTerrainMap[Index][Inner].rawValue][DTerrainMap[Index][(Inner - 1)].rawValue] {
                        return ReturnStatus
                    }
                    //  }
                    //  if(Index) { to do confused on this part?
                    if !CTerrainMap.DAllowedAdjacent[DTerrainMap[Index][Inner].rawValue][DTerrainMap[Index - 1][Inner].rawValue] {
                        return ReturnStatus
                    }
                    // }
                }
            }
            StringMap.removeAll()
            while StringMap.count < MapHeight + 1 {
                if !LineSource.Read(line: &TempString) {
                    return ReturnStatus
                }
                StringMap.append(TempString)
                if MapWidth + 1 > StringMap.last!.count {
                    return ReturnStatus
                }
            }
            if MapHeight + 1 > StringMap.count {
                return ReturnStatus
            }
            resize(array: &DPartials, size: MapHeight + 1, defaultValue: [0x0])
            for Index in 0 ..< DTerrainMap.count {
                resize(array: &DPartials, size: MapWidth + 1, defaultValue: [0x0])
                for Inner in 0 ..< MapWidth + 1 {
                    let index: String.Index = StringMap[Index].index(StringMap[Index].startIndex, offsetBy: Inner)
                    let valueStringValues: [Character] = ["0", "A"]
                    var asciiValues: [UInt8] = String(valueStringValues).utf8.map { UInt8($0) }
                    let intValue: UInt8 = String(StringMap[Index][index]).utf8.map { UInt8($0) }[0]
                    if ("0" <= StringMap[Index][index]) && ("9" >= StringMap[Index][index]) {
                        DPartials[Index][Inner] = intValue - asciiValues[0]
                    } else if ("A" <= StringMap[Index][index]) && ("F" >= StringMap[Index][index]) {
                        DPartials[Index][Inner] = intValue - asciiValues[1] + 0x0A
                    } else {
                        return ReturnStatus
                    }
                }
            }
            ReturnStatus = true
        }
        return ReturnStatus
        //  catch {
        //      print("LoadMap function Error (TerrainMap.swift)")
        // }
    }
}
