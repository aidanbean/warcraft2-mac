//
//  AssetDecoratedMap.swift
//  WarCraft2
//
//  Created by Alan Sin on 19/10/2017.
//  Copyright © 2017 UC Davis. All rights reserved.
//
// Getters and setters all removed.
import Foundation

class CAssetDecoratedMap: CTerrainMap {
    public struct SAssetInitialization {
        var DType: String
        var DColor: EPlayerColor
        var DTilePosition: CTilePosition
    }

    public struct SResourceInitialization {
        var DColor: EPlayerColor
        var DGold: Int
        var DLumber: Int
    }

    var DAssets: [CPlayerAsset]
    var DAssetInitializationList: [SAssetInitialization]
    var DResourceInitializationList: [SResourceInitialization]
    var DSearchMap: [[Int]]
    var DLumberAvailable: [[Int]]

    var DMapNameTranslation: [String: Int]
    var DAllMaps: [CAssetDecoratedMap] // originally a vector, might need different implementation.

    // start of functions

    override init() {
        DAssets = []
    }

    init(map: CAssetDecoratedMap) {
        DAssets = map.DAssets
        DLumberAvailable = map.DLumberAvailable
        DAssetInitializationList = map.DAssetInitializationList
        DResourceInitializationList = map.DResourceInitializationList
    }

    init(map: CAssetDecoratedMap, newcolors: [EPlayerColor]) { // const std::array< EPlayerColor, to_underlying(EPlayerColor::Max)> not entirely sure if it equals to [[int]]

        DAssets = map.DAssets
        DLumberAvailable = map.DLumberAvailable
        for InitVal in map.DAssetInitializationList {
            var NewInitVal = InitVal
            if newcolors.count > NewInitVal.DColor.rawValue {
                NewInitVal.DColor = newcolors[NewInitVal.DColor.rawValue]
            }
            DAssetInitializationList.append(NewInitVal)
        }
        for InitVal in map.DResourceInitializationList {
            var NewInitVal = InitVal
            if newcolors.count > NewInitVal.DColor.rawValue {
                NewInitVal.DColor = newcolors[NewInitVal.DColor.rawValue]
            }
            DResourceInitializationList.append(NewInitVal)
        }
    }

    deinit {
    }

    // constructors and destructors end

    func LoadMaps(container: CDataContainer) -> Bool {
        var FileIterator: CDataContainerIterator! = container.First()
        if FileIterator == nil {
            print("FileIterator == nullptr\n")
            return false
        }
        while ((FileIterator != nil)) && (FileIterator.IsValid()) {
            var Filename: String = FileIterator.Name()
            FileIterator.Next()
            if Filename.range(of: ".map") != nil {
                var TempMap: CAssetDecoratedMap = CAssetDecoratedMap()

                if !TempMap.LoadMap(source: container.DataSource(name: Filename)) {
                    print("Failed to load map \"%s\".\n", Filename)
                    continue
                } else {
                    print("Loaded map \"%s\".\n", Filename)
                }
                TempMap.RenderTerrain()
                DMapNameTranslation[TempMap.MapName()] = DAllMaps.count
                DAllMaps.append(TempMap)
            }
        }
        print("Maps loaded\n")
        return true
    }

    func FindMapIndex(name: String) -> Int {
        let Iterator: Int! = DMapNameTranslation[name]
        if Iterator != nil {
            return Iterator
        }
        return -1
    }

    func GetMap(index: Int) -> CAssetDecoratedMap {
        if (0 > index) || (DAllMaps.count <= index) {
            return CAssetDecoratedMap()
        }
        return CAssetDecoratedMap(map: DAllMaps[index])
    }

    func DuplicateMap(index: Int, newcolors: [EPlayerColor]) -> CAssetDecoratedMap {
        if (0 > index) || (DAllMaps.count <= index) {
            return CAssetDecoratedMap()
        }
        return CAssetDecoratedMap(map: DAllMaps[index], newcolors: newcolors)
    }

    func AddAsset(asset: CPlayerAsset) -> Bool {
        DAssets.append(asset)
        return true
    }

    func RemoveAsset(asset: CPlayerAsset) -> Bool {
        for var index: Int in 0 ... DAssets.count {
            if DAssets[index] === asset { // not certain if this will work, if not we need to make CPlayerAsset equatable
                DAssets.remove(at: index)
                return true
            }
        }
        return false
    }

    func CanPlaceAsset(pos: CTilePosition, size: Int, ignoreasset _: CPlayerAsset) -> Bool {
        var RightX: Int
        var BottomY: Int

        for var YOff: Int in stride(from: 0, to: size, by: 1) {
            for var XOff: Int in stride(from: 0, to: size, by: 1) {
                var TileTerrainType = TileType(xindex: pos.X() + XOff, yindex: pos.Y() + YOff)
                if !CanPlaceOn(type: TileTerrainType) {
                    return false
                }
            }
        }
        RightX = pos.X() + size
        BottomY = pos.Y() + size
        if RightX >= Width() {
            return false
        }
        if BottomY >= Height() {
            return false
        }
        for Asset in DAssets {
            var Offset: Int = (EAssetType.GoldMine == Asset.Type() ? 1 : 0)

            if EAssetType.None == Asset.Type() {
                continue
            }
            //            if ignoreasset == Asset {
            //                continue
            //            }
            if RightX <= Asset.TilePositionX() - Offset {
                continue
            }
            if pos.X() >= (Asset.TilePositionX() + Asset.Size() + Offset) {
                continue
            }
            if BottomY <= Asset.TilePositionY() - Offset {
                continue
            }
            if pos.Y() >= (Asset.TilePositionY() + Asset.Size() + Offset) {
                continue
            }
            return false
        }
        return true
    }

    func FindAssetPlacement(placeasset: CPlayerAsset, fromasset: CPlayerAsset, nexttiletarget: CTilePosition) -> CTilePosition {
        var TopY: Int, BottomY: Int, LeftX: Int, RightX: Int
        var BestDistance: Int = -1
        var CurDistance: Int
        var BestPosition = CTilePosition(x: 1, y: -1)
        TopY = fromasset.TilePositionY() - placeasset.Size()
        BottomY = fromasset.TilePositionY() + fromasset.Size()
        LeftX = fromasset.TilePositionX() - placeasset.Size()
        RightX = fromasset.TilePositionX() + fromasset.Size()
        while true {
            var Skipped: Int = 0
            if 0 <= TopY {
                var ToX: Int = min(RightX, Width() - 1)
                for var CurX: Int in stride(from: max(LeftX, 0), to: ToX, by: 1) {
                    if CanPlaceAsset(pos: CTilePosition(x: CurX, y: TopY), size: placeasset.Size(), ignoreasset: placeasset) {
                        var TempPosition = CTilePosition(x: CurX, y: TopY)
                        CurDistance = TempPosition.DistanceSquared(pos: nexttiletarget)
                        if (-1 == BestDistance) || (CurDistance < BestDistance) {
                            BestDistance = CurDistance
                            BestPosition = TempPosition
                        }
                    }
                }
            } else {
                Skipped = Skipped + 1
            }
            if Width() > RightX {
                var ToY: Int = min(BottomY, Height() - 1)
                for var CurY: Int in stride(from: max(TopY, 0), to: ToY, by: 1) {
                    if CanPlaceAsset(pos: CTilePosition(x: RightX, y: CurY), size: placeasset.Size(), ignoreasset: placeasset) {
                        var TempPosition = CTilePosition(x: RightX, y: CurY)
                        CurDistance = TempPosition.DistanceSquared(pos: nexttiletarget)
                        if (-1 == BestDistance) || (CurDistance < BestDistance) {
                            BestDistance = CurDistance
                            BestPosition = TempPosition
                        }
                    }
                }
            } else {
                Skipped = Skipped + 1
            }
            if Height() > BottomY {
                var ToX: Int = max(LeftX, 0)
                for var CurX: Int in stride(from: min(RightX, Width() - 1), to: ToX, by: -1) {
                    if CanPlaceAsset(pos: CTilePosition(x: CurX, y: BottomY), size: placeasset.Size(), ignoreasset: placeasset) {
                        var TempPosition = CTilePosition(x: CurX, y: BottomY)
                        CurDistance = TempPosition.DistanceSquared(pos: nexttiletarget)
                        if (-1 == BestDistance) || (CurDistance < BestDistance) {
                            BestDistance = CurDistance
                            BestPosition = TempPosition
                        }
                    }
                }
            } else {
                Skipped = Skipped + 1
            }
            if 0 <= LeftX {
                var ToY: Int = max(TopY, 0)
                for var CurY: Int in stride(from: min(BottomY, Height() - 1), to: ToY, by: -1) {
                    if CanPlaceAsset(pos: CTilePosition(x: LeftX, y: CurY), size: placeasset.Size(), ignoreasset: placeasset) {
                        var TempPosition = CTilePosition(x: LeftX, y: CurY)
                        CurDistance = TempPosition.DistanceSquared(pos: nexttiletarget)
                        if (-1 == BestDistance) || (CurDistance < BestDistance) {
                            BestDistance = CurDistance
                            BestPosition = TempPosition
                        }
                    }
                }
            } else {
                Skipped = Skipped + 1
            }
            if 4 == Skipped {
                break
            }
            if -1 != BestDistance {
                break
            }
            TopY = TopY - 1
            BottomY = BottomY + 1
            LeftX = LeftX - 1
            RightX = RightX + 1
        }
        return BestPosition
    }

    func FindNearestAsset(pos: CPixelPosition, color: EPlayerColor, type: EAssetType) -> CPlayerAsset {
        var BestAsset: CPlayerAsset
        var BestDistanceSquared: Int = -1
        for Asset in DAssets {
            if (Asset.Type() == type) && (Asset.Color() == color) && (EAssetAction.Construct != Asset.Action()) {
                var CurrentDistance: Int = Asset.DPosition.DistanceSquared(pos: pos)
                if (-1 == BestDistanceSquared) || (CurrentDistance < BestDistanceSquared) {
                    BestDistanceSquared = CurrentDistance
                    BestAsset = Asset
                }
            }
        }
        return BestAsset
    }

    func RemoveLumber(pos: CTilePosition, from: CTilePosition, amount: Int) {
        var Index: Int! = 0
        for var YOff: Int in stride(from: 0, to: 2, by: 1) {
            for var XOff: Int in stride(from: 0, to: 2, by: 1) {
                var XPos: Int = pos.X() + XOff
                var YPos: Int = pos.Y() + YOff
                Index! |= (ETerrainTileType.Forest == DTerrainMap[YPos][XPos]) && (DPartials.count <= YPos && DPartials[YPos].count <= XPos) ? 1 << (YOff * 2 + XOff) : 0
            }
        }
        if Index != nil && (0xF != Index) {
            switch Index {
            case 1: Index = 0
                break
            case 2: Index = 1
                break
            case 3: Index = from.X() > pos.X() ? 1 : 0
                break
            case 4: Index = 2
                break
            case 5: Index = from.Y() < pos.Y() ? 0 : 2
                break
            case 6: Index = from.Y() > pos.Y() ? 2 : 1
                break
            case 7: Index = 2
                break
            case 8: Index = 3
                break
            case 9: Index = from.Y() > pos.Y() ? 0 : 3
                break
            case 10: Index = from.Y() > pos.Y() ? 3 : 1
                break
            case 11: Index = 0
                break
            case 12: Index = from.X() < pos.X() ? 2 : 3
                break
            case 13: Index = 3
                break
            case 14: Index = 1
                break
            default:
                break
            }
            switch Index {
            case 0: DLumberAvailable[pos.Y()][pos.X()] -= amount
                if 0 >= DLumberAvailable[pos.Y()][pos.X()] {
                    DLumberAvailable[pos.Y()][pos.X()] = 0
                    ChangeTerrainTilePartial(xindex: pos.X(), yindex: pos.Y(), val: 0)
                }
                break
            case 1: DLumberAvailable[pos.Y()][pos.X() + 1] -= amount
                if 0 >= DLumberAvailable[pos.Y()][pos.X() + 1] {
                    DLumberAvailable[pos.Y()][pos.X() + 1] = 0
                    ChangeTerrainTilePartial(xindex: pos.X() + 1, yindex: pos.Y(), val: 0)
                }
                break
            case 2: DLumberAvailable[pos.Y() + 1][pos.X()] -= amount
                if 0 >= DLumberAvailable[pos.Y() + 1][pos.X()] {
                    DLumberAvailable[pos.Y() + 1][pos.X()] = 0
                    ChangeTerrainTilePartial(xindex: pos.X(), yindex: pos.Y() + 1, val: 0)
                }
                break
            case 3: DLumberAvailable[pos.Y() + 1][pos.X() + 1] -= amount
                if 0 >= DLumberAvailable[pos.Y() + 1][pos.X() + 1] {
                    DLumberAvailable[pos.Y() + 1][pos.X() + 1] = 0
                    ChangeTerrainTilePartial(xindex: pos.X() + 1, yindex: pos.Y() + 1, val: 0)
                }
                break
            default:
                break
            }
        }
    }

    func LoadMap(source: CDataSource) -> Bool {
        var LineSource = CCommentSkipLineDataSource(source: source, commentchar: "#") //there is a '#' here and not entirely sure how to handle it.
        var TempString: String
        var Tokens: [String]
        var TempResourceInit: SResourceInitialization
        var TempAssetInit: SAssetInitialization
        var ResourceCount: Int, AssetCount: Int
        var InitialLumber: Int = 400
        var ReturnStatus: Bool = false
        if !LoadMap(source: source) {
            return false
        }
        if !LineSource.Read(line: &TempString) { // supposingly where try starts
            print("Failed To read map resource count.\n")
            return ReturnStatus
        }
        ResourceCount = Int(TempString)!
        DResourceInitializationList.removeAll()
        for var Index: Int in stride(from: 0, to: ResourceCount, by: 1) {
            if !LineSource.Read(line: &TempString) {
                print("Failed to read map resource %d.\n", Index)
                return ReturnStatus
            }
            CTokenizer.Tokenize(tokens: &Tokens, data: TempString, delimiters: "")
            if 3 > Tokens.count {
                print("Too few tokens for resource %d.\n", Index)
                return ReturnStatus
            }
            TempResourceInit.DColor = EPlayerColor(rawValue: Int(Tokens[0])!)!
            if (0 == Index) && (EPlayerColor.None != TempResourceInit.DColor) {
                print("Expected first resource to be for color None.\n")
                return ReturnStatus
            }
            TempResourceInit.DGold = Int(Tokens[1])!
            TempResourceInit.DLumber = Int(Tokens[2])!
            if EPlayerColor.None == TempResourceInit.DColor {
                InitialLumber = TempResourceInit.DLumber
            }

            DResourceInitializationList.append(TempResourceInit)
        }

        if !LineSource.Read(line: &TempString) {
            print("Failed to read map asset count.\n")
            return ReturnStatus
        }
        AssetCount = Int(TempString)!
        DAssetInitializationList.removeAll()
        for var Index: Int in stride(from: 0, to: AssetCount, by: 1) {
            if !LineSource.Read(line: &TempString) {
                print("Failed to read map asset %d.\n", Index)
                return ReturnStatus
            }
            CTokenizer.Tokenize(tokens: &Tokens, data: TempString)
            if 4 > Tokens.count {
                print("Too few tokens for asset %d.\n", Index)
                return ReturnStatus
            }
            TempAssetInit.DType = Tokens[0]
            TempAssetInit.DColor = EPlayerColor(rawValue: Int(Tokens[1])!)!
            TempAssetInit.DTilePosition.X(x: Int(Tokens[2])!)
            TempAssetInit.DTilePosition.Y(y: Int(Tokens[3])!)

            if (0 > TempAssetInit.DTilePosition.X()) || (0 > TempAssetInit.DTilePosition.Y()) {
                print("Invalid resource position %d (%d, %d).\n", Index, TempAssetInit.DTilePosition.X(), TempAssetInit.DTilePosition.Y())
                return ReturnStatus
            }
            if (Width() <= TempAssetInit.DTilePosition.X()) || (Height() <= TempAssetInit.DTilePosition.Y()) {
                print("Invalid resource position %d (%d, %d).\n", Index, TempAssetInit.DTilePosition.X(), TempAssetInit.DTilePosition.Y())
                return ReturnStatus
            }
            DAssetInitializationList.append(TempAssetInit)
        }

        resize(array: &DLumberAvailable, size: DTerrainMap.count, defaultValue: [])
        for var RowIndex: Int in stride(from: 0, to: DLumberAvailable.count, by: 1) {
            resize(array: &DLumberAvailable[RowIndex], size: DTerrainMap[RowIndex].count, defaultValue: Int())
            for var ColIndex: Int in stride(from: 0, to: DTerrainMap[RowIndex].count, by: 1) {
                if ETerrainTileType.Forest == DTerrainMap[RowIndex][ColIndex] {
                    DLumberAvailable[RowIndex][ColIndex] = DPartials.count <= RowIndex && DPartials[RowIndex].count <= ColIndex ? InitialLumber : 0
                } else {
                    DLumberAvailable[RowIndex][ColIndex] = 0
                }
            }
        }
        ReturnStatus = true // supposingly where try ends and where catch begins
    }

    func CreateInitializeMap() -> CAssetDecoratedMap {
        var ReturnMap: CAssetDecoratedMap = CAssetDecoratedMap()

        if ReturnMap.DMap.count != DMap.count {
            ReturnMap.DTerrainMap = DTerrainMap
            ReturnMap.DPartials = DPartials

            // Initialize to empty grass
            resize(array: &ReturnMap.DMap, size: DMap.count, defaultValue: [])
            for var Row in ReturnMap.DMap {
                resize(array: &Row, size: DMap[0].count, defaultValue: CTerrainMap.ETileType.None)
                for var Cell in Row {
                    Cell = ETileType.None
                }
            }
            resize(array: &ReturnMap.DMapIndices, size: DMap.count, defaultValue: [])
            for var Row in ReturnMap.DMapIndices {
                resize(array: &Row, size: DMapIndices[0].count, defaultValue: Int())
                for var Cell in Row {
                    Cell = 0
                }
            }
        }
        return ReturnMap
    }

    //    func CreateVisibilityMap() -> PVisibilityMap{ TODO: something wrong with MaxSight.
    //        return PVisibilityMap(width: Width(),height: Height(),maxvisibility: CPlayerAssetType.MaxSight());
    //    }

    func UpdateMap(vismap: CVisibilityMap, resmap: CAssetDecoratedMap) -> Bool {
        var Iterator = DAssets[0]

        if DMap.count != resmap.DMap.count {
            DTerrainMap = resmap.DTerrainMap
            DPartials = resmap.DPartials
            resize(array: &DMap, size: resmap.DMap.count, defaultValue: [])
            for var Row in DMap {
                resize(array: &Row, size: resmap.DMap[0].count, defaultValue: CTerrainMap.ETileType.None)
                for var Cell in Row {
                    Cell = ETileType.None
                }
            }
            resize(array: &DMapIndices, size: resmap.DMapIndices.count, defaultValue: [])
            for var Row in DMapIndices {
                resize(array: &Row, size: resmap.DMapIndices[0].count, defaultValue: Int())
                for var Cell in Row {
                    Cell = 0
                }
            }
        }
        while Iterator != DAssets[DAssets.count] {
            var CurPosition: CTilePosition = Iterator.TilePosition()
            var AssetSize: Int = Iterator.Size()
            var RemoveAsset: Bool = false
            if (Iterator.Speed() != 0) || (EAssetAction.Decay == Iterator.Action()) || (EAssetAction.Attack == Iterator.Action()) { //  Remove all movable units
                // https://stackoverflow.com/questions/24092712/how-to-remove-an-element-of-a-given-value-from-an-array-in-swift
                for var itemToRemoveIndex: Int in stride(from: 0, to: DAssets.count, by: 1) {
                    if !(DAssets[itemToRemoveIndex] != Iterator) {
                        DAssets.remove(at: itemToRemoveIndex)
                        Iterator = DAssets[itemToRemoveIndex + 1]
                    }
                } // FIXME: this is essentially array.erase(object).
                continue
            }
            for var YOff: Int in stride(from: 0, to: AssetSize, by: 1) {
                var YPos: Int = CurPosition.Y() + YOff
                for var XOff: Int in stride(from: 0, to: AssetSize, by: 1) {
                    var XPos: Int = CurPosition.X() + XOff

                    var VisType: ETileVisibility = vismap.TileType(xindex: XPos, yindex: YPos)
                    if (ETileVisibility.Partial == VisType) || (ETileVisibility.PartialPartial == VisType) || (ETileVisibility.Visible == VisType) { // Remove visible so they can be updated
                        RemoveAsset = EAssetType.None != Iterator.Type()
                        break
                    }
                }
                if RemoveAsset {
                    break
                }
            }
            if RemoveAsset {
                for var itemToRemoveIndex: Int in stride(from: 0, to: DAssets.count, by: 1) {
                    if !(DAssets[itemToRemoveIndex] != Iterator) {
                        DAssets.remove(at: itemToRemoveIndex)
                        Iterator = DAssets[itemToRemoveIndex + 1]
                    }
                }
                continue
            }
            // Iterator ++ FIXME
            for var itemToRemoveIndex: Int in stride(from: 0, to: DAssets.count, by: 1) {
                if !(DAssets[itemToRemoveIndex] != Iterator) {
                    Iterator = DAssets[itemToRemoveIndex + 1]
                }
            }
        }
        for var YPos: Int in stride(from: 0, to: DMap.count, by: 1) {
            for var XPos: Int in stride(from: 0, to: DMap[YPos].count, by: 1) {
                var VisType: ETileVisibility = vismap.TileType(xindex: XPos - 1, yindex: YPos - 1)
                if (ETileVisibility.Partial == VisType) || (ETileVisibility.PartialPartial == VisType) || (ETileVisibility.Visible == VisType) {
                    DMap[YPos][XPos] = resmap.DMap[YPos][XPos]
                    DMapIndices[YPos][XPos] = resmap.DMapIndices[YPos][XPos]
                }
            }
        }
        for var Asset in resmap.DAssets {
            var CurPosition: CTilePosition = Asset.TilePosition()
            var AssetSize: Int = Asset.Size()
            var AddAsset: Bool = false

            for var YOff: Int in stride(from: 0, to: AssetSize, by: 1) {
                var YPos: Int = CurPosition.Y() + YOff
                for var XOff: Int in stride(from: 0, to: AssetSize, by: 1) {
                    var XPos: Int = CurPosition.X() + XOff
                    var VisType: ETileVisibility = vismap.TileType(xindex: XPos, yindex: YPos)
                    if (ETileVisibility.Partial == VisType) || (ETileVisibility.PartialPartial == VisType) || (ETileVisibility.Visible == VisType) { // Add visible resources
                        AddAsset = true
                        break
                    }
                }
                if AddAsset {
                    DAssets.append(Asset)
                    break
                }
            }
        }

        return true
    }

    let SEARCH_STATUS_UNVISITED = 0
    let SEARCH_STATUS_QUEUED = 1
    let SEARCH_STATUS_VISITED = 2

    struct SSearchTile {
        var DX: Int
        var DY: Int
    }

    func FindNearestReachableTileType(pos: CTilePosition, type: ETileType) -> CTilePosition {
        var SearchQueue: [SSearchTile]
        var CurrentSearch: SSearchTile, TempSearch: SSearchTile
        var MapWidth: Int = Width()
        var MapHeight: Int = Height()
        var SearchXOffsets: [Int] = [0, 1, 0, -1]
        var SearchYOffsets: [Int] = [-1, 0, 1, 0]

        if DSearchMap.count != DMap.count {
            resize(array: &DSearchMap, size: DMap.count, defaultValue: [])
            for var Row in DSearchMap {
                resize(array: &Row, size: DMap[0].count, defaultValue: Int())
                for var Cell in Row {
                    Cell = 0
                }
            }
            var LastYIndex: Int = DMap.count - 1
            var LastXIndex: Int = DMap[0].count - 1
            for var Index: Int in stride(from: 0, to: DMap.count, by: 1) {
                DSearchMap[Index][0] = SEARCH_STATUS_VISITED
                DSearchMap[Index][LastXIndex] = SEARCH_STATUS_VISITED
            }
            for var Index: Int in stride(from: 1, to: LastXIndex, by: 1) {
                DSearchMap[0][Index] = SEARCH_STATUS_VISITED
                DSearchMap[LastYIndex][Index] = SEARCH_STATUS_VISITED
            }
        }
        for var Y: Int in stride(from: 0, to: MapHeight, by: 1) {
            for var X: Int in stride(from: 0, to: MapWidth, by: 1) {
                DSearchMap[Y + 1][X + 1] = SEARCH_STATUS_UNVISITED
            }
        }
        for var Asset in DAssets {
            if Asset.TilePosition() != pos {
                for var Y: Int in stride(from: 0, to: Asset.Size(), by: 1) {
                    for var X: Int in stride(from: 0, to: Asset.Size(), by: 1) {
                        DSearchMap[Asset.TilePositionY() + Y + 1][Asset.TilePositionX() + X + 1] = SEARCH_STATUS_VISITED
                    }
                }
            }
        }

        CurrentSearch.DX = pos.X() + 1
        CurrentSearch.DY = pos.Y() + 1
        SearchQueue.append(CurrentSearch)
        while SearchQueue.count != 0 {
            CurrentSearch = SearchQueue.first!
            SearchQueue.removeFirst()
            DSearchMap[CurrentSearch.DY][CurrentSearch.DX] = SEARCH_STATUS_VISITED
            for var Index: Int in stride(from: 0, to: SearchXOffsets.count, by: 1) {
                TempSearch.DX = CurrentSearch.DX + SearchXOffsets[Index]
                TempSearch.DY = CurrentSearch.DY + SearchYOffsets[Index]
                if SEARCH_STATUS_UNVISITED == DSearchMap[TempSearch.DY][TempSearch.DX] {
                    var CurTileType: ETileType = DMap[TempSearch.DY][TempSearch.DX]

                    DSearchMap[TempSearch.DY][TempSearch.DX] = SEARCH_STATUS_QUEUED
                    if type == CurTileType {
                        return CTilePosition(x: TempSearch.DX - 1, y: TempSearch.DY - 1)
                    }
                    // if((ETileType::Grass == CurTileType)||(ETileType::Dirt == CurTileType)||(ETileType::Stump == CurTileType)||(ETileType::Rubble == CurTileType)||(ETileType::None == CurTileType)){
                    if IsTraversable(type: CurTileType) {
                        SearchQueue.append(TempSearch)
                    }
                }
            }
        }
        return CTilePosition(x: -1, y: -1)
    }
}