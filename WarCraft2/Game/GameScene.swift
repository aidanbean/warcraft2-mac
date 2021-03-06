//
//  GameScene.swift
//  WarCraft2
//
//  Created by Yepu Xie on 11/11/17.
//  Copyright © 2017 UC Davis. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    var applicationData: CApplicationData
    var battleMode: CBattleMode

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(size: CGSize, applicationData: CApplicationData, battleMode: CBattleMode) {
        self.applicationData = applicationData
        self.battleMode = battleMode
        super.init(size: size)
        anchorPoint = CGPoint(x: 0, y: 1)
    }

    override func update(_: CFTimeInterval) {
        clean()
        applicationData.DViewportSurface = self
        battleMode.Input(context: applicationData)
        battleMode.Calculate(context: applicationData)
        battleMode.Render(context: applicationData)
        if !applicationData.DLeftDown || applicationData.DLeftClick != 2 {
            applicationData.DLeftClick = 0
        }

        applicationData.DRightClick = 0
    }

    func renderMap() {
        let rect = SRectangle(DXPosition: 0, DYPosition: 0, DWidth: 0, DHeight: 0)
        let cgr = CGraphicResourceContext()
    }

    func clean() {
        removeAllChildren()
    }
}
