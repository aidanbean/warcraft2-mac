//
//  GameViewController.swift
//  WarCraft2
//
//  Created by Yepu Xie on 10/12/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation
import Cocoa
import SpriteKit

class GameViewController: NSViewController {

    var skview = SKView(frame: NSRect(x: 0, y: 0, width: 1400, height: 900))
    var skscene = SKScene(fileNamed: "Scene")
    var rect: SRectangle = SRectangle()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.addSubview(skview)
        //                skview.showsFPS = true
        // skscene?.backgroundColor = NSColor.brown
        skview.presentScene(skscene)
        let graphicTileSet = CGraphicTileset()
        graphicTileSet.LoadTileset(source: nil)
        let map = CTerrainMap()
        try! map.LoadMap()
        map.RenderTerrain()
        let mapRenderer = CMapRenderer(config: nil, tileset: graphicTileSet, map: map)
        mapRenderer.DrawMap(surface: skscene!, typesurface: skscene!, rect: rect)
        // TODO:
        //        graphicTileSet.LoadTileset(source: nil)
        //        graphicTileSet.DrawTest(skscene: skscene!, xpos: -700, ypos: 330)
    }
}
