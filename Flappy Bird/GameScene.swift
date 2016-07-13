//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Darwing Medina on 20/4/16.
//  Copyright (c) 2016 Darwing Medina. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var movingObjects = SKSpriteNode()
    
    let birdGroup:UInt32 = 1
    let objectGroup:UInt32 = 2
    let gapGroup:UInt32 = 1 << 2 // 4
    
    var gameOver = false
    
    var timer = NSTimer()
    
    var score = 0
    
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self // definimos el delegado de los contactos
        self.physicsWorld.gravity = CGVectorMake(0, -5.0)
        
        self.scoreLabel.fontName = "Helvetica"
        self.scoreLabel.fontSize = 60
        self.scoreLabel.text = "0"
        self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        self.scoreLabel.zPosition = 40
        
        addChild(self.scoreLabel)
        
        // Pájaro
        
        makeBackground()
        
        self.addChild(movingObjects)
        
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        let animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        
        
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bird.zPosition = 10 // esta encima de todo
        
        bird.runAction(makeBirdFlap)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width/2) // le asignamos una forma de cirulo
        bird.physicsBody?.dynamic = true // que le afecta la gravedad
        bird.physicsBody?.allowsRotation = false
        
        // coliciones
        bird.physicsBody?.categoryBitMask = birdGroup
        bird.physicsBody?.collisionBitMask = objectGroup
        bird.physicsBody?.contactTestBitMask = objectGroup | gapGroup
        
        self.addChild(bird)
        
        // tierra
        
        let ground = SKNode() // Nodo de la tierra, no es visible
        ground.position = CGPointMake(0,0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.width * 2, 1))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = objectGroup
        
        
        self.addChild(ground)
        
        // Tuberias
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("createPipes"), userInfo: nil, repeats: true)
        
    }
    
    func makeBackground() {
        //fondo
        
        let backgroundTexture = SKTexture(imageNamed: "bg.png")
        
        let moveBG = SKAction.moveByX(-backgroundTexture.size().width, y: 0, duration: 9) // mover en eje X el fondo
        let replaceBG = SKAction.moveByX(backgroundTexture.size().width, y: 0, duration: 0)
        let moveBGForever = SKAction.repeatActionForever(SKAction.sequence([moveBG,replaceBG]))
        
        for var i:CGFloat = 0 ; i < 3; i++ {
            
            background = SKSpriteNode(texture: backgroundTexture)
            background.position = CGPoint(x: (backgroundTexture.size().width / 2) + (backgroundTexture.size().width * i) , y: CGRectGetMidY(self.frame))
            background.size.height = self.frame.height
            background.zPosition = 1
            
            background.runAction(moveBGForever)
            
            self.movingObjects.addChild(background)
        }
    }
    
    func createPipes() {
        
        let gapHeight = bird.size.height * 4 // tamño hueco entre tuberias
        let movementAmount = arc4random_uniform(UInt32(self.frame.size.height / 2))
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4 // que la tuberia aparezca en 1/4 de pantalla
        
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        
        let movePipes = SKAction.moveByX(-(self.frame.size.width + (pipeTexture.size().width * 2)), y: 0, duration: NSTimeInterval(self.size.width / 100)) // damos un tiempo respectivo a la pantalla
        let removePipes = SKAction.removeFromParent() // quitar de la pantalla
        let moveAndRemovePipes = SKAction.sequence([movePipes,removePipes])
        
        var pipeUp = SKSpriteNode()
        pipeUp = SKSpriteNode(texture: pipeTexture)
        pipeUp.position = CGPoint(x: self.frame.size.width + pipeTexture.size().width, y: CGRectGetMidY(self.frame) + (pipeUp.size.height/2) + (gapHeight / 2) + pipeOffset)
        
        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody?.dynamic = false
        pipeUp.physicsBody?.categoryBitMask = objectGroup
        
        
        pipeUp.zPosition = 5
        pipeUp.runAction(movePipes)
        
        self.movingObjects.addChild(pipeUp)
        
        var pipeDown = SKSpriteNode()
        pipeDown = SKSpriteNode(texture: pipeTexture2)
        pipeDown.position = CGPoint(x: self.frame.size.width + pipeTexture2.size().width, y: CGRectGetMidY(self.frame) - (pipeDown.size.height/2) - (gapHeight / 2) + pipeOffset)
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize: pipeDown.size)
        pipeDown.physicsBody?.dynamic = false
        pipeDown.physicsBody?.categoryBitMask = objectGroup
        
        pipeDown.zPosition = 6
        
        pipeDown.runAction(moveAndRemovePipes)
        
        self.movingObjects.addChild(pipeDown)
        
        let gap = SKNode()
        // let gap = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(pipeUp.size.width, gapHeight))
        gap.position = CGPointMake(self.frame.size.width + pipeTexture.size().width, CGRectGetMidY(self.frame) + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipeUp.size.width, gapHeight))
        gap.physicsBody?.dynamic = false
        
        gap.physicsBody?.categoryBitMask = gapGroup
        
        gap.runAction(moveAndRemovePipes)
        
        gap.zPosition = 30
        
        
        self.movingObjects.addChild(gap)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        if !gameOver { // if not gameOver
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0,60))
        }
        else {
            score = 0
            scoreLabel.text = "0"
            movingObjects.removeAllChildren() // quitamos los elementos pasados
            makeBackground() // volvemos a poner el fondo
            self.timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("createPipes"), userInfo: nil, repeats: true) // otra vez generamos tuberias
            
            bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)) // ponemos el ave en el centro
            
            bird.physicsBody?.velocity = CGVectorMake(0, 0) // reiniciamos su velocidad
            
            self.gameOverLabel.removeFromParent()
            
            self.movingObjects.speed = 1
            
            gameOver = false
            

        }
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup {
            score++
            self.scoreLabel.text = "\(score)"
        }
        else if !gameOver {
            self.gameOver = true
            self.movingObjects.speed = 0
            timer.invalidate()
            
            self.gameOverLabel.fontName = "Helvetica"
            self.gameOverLabel.fontSize = 30
            self.gameOverLabel.text = "Toca para intentarlo de nuevo"
            self.gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            self.gameOverLabel.zPosition = 50
            
            addChild(self.gameOverLabel)
        }
        
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
