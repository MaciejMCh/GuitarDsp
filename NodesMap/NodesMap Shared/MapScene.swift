//
//  GameScene.swift
//  NodesMap Shared
//
//  Created by Maciej Chmielewski on 29.09.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import SpriteKit

extension SpriteScene {
    enum Interaction {
        case on(CGPoint)
        case drag(CGPoint)
        case off(CGPoint)
    }
}

public class SpriteScene: SKScene {
    var interaction: ((Interaction) -> Void)?
    
    #if os(OSX)
    // Mouse-based event handling
    
    public override func mouseDown(with event: NSEvent) {
        interaction?(.on(event.location(in: self)))
    }
    
    public override func mouseDragged(with event: NSEvent) {
        interaction?(.drag(event.location(in: self)))
    }
    
    public override func mouseUp(with event: NSEvent) {
        interaction?(.off(event.location(in: self)))
    }
    
    #endif

#if os(iOS)
    private func touchDown(atPoint pos : CGPoint) {
    interaction?(.on(pos))
    }
    
    private func touchMoved(toPoint pos : CGPoint) {
    interaction?(.drag(pos))
    }
    
    private func touchUp(atPoint pos : CGPoint) {
    interaction?(.off(pos))
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
#endif
}
