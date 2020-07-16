//
//  GameScene.swift
//  ElongTuff
//
//  Created by Rafael Marques on 16/06/2020.
//  Copyright © 2020 Rafael Marques. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
     var gameScore = 0
    let scoreLabel = SKLabelNode(fontNamed: "the Bold Font")
    
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "the bold font")
    
    
    
    var levelNumber = 0
    
    let player = SKSpriteNode (imageNamed: "ElongMuskOriginal")
    let level0music = SKAudioNode(fileNamed: "level0")
    let bulletSound = SKAction.playSoundFileNamed("bulletSound.mp3", waitForCompletion: false)
   
    
    struct PhysicsCategories {
        static let None: UInt32 = 0
        static let player:UInt32 = 0b1 //1
        static let Bullet : UInt32 = 0b1 //2
        static let Enemy: UInt32 = 0b100 //4
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random())/0xFFFFFFFF)
        
    }
    
    func random( min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
        
        
    }

        
        
    var gamearea: CGRect
    
    override init(size:CGSize){
        
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gamearea = CGRect(x:margin , y:0, width:playableWidth, height: size.height)
        
        
        
        
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func didMove(to view: SKView) {
           self.physicsWorld.contactDelegate = self
           
           
           let background = SKSpriteNode(imageNamed: "background")
           background.size = self.size
           background.position =  CGPoint(x: self.size.width/3, y: self.size.height/2)
           background.zPosition=0
           
           self.addChild(background)
           self.addChild(level0music)
           
           
           player.setScale(0.4)
           player.position = CGPoint (x: self.size.width/2, y: self.size.height * 0.2)
           player.zPosition = 2
           player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
           player.physicsBody!.affectedByGravity = false
           player.physicsBody!.categoryBitMask = PhysicsCategories.player
           player.physicsBody!.collisionBitMask = PhysicsCategories.None
           player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
           self.addChild(player)
        
        scoreLabel.text = "Score:0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.21, y: self.size.height*0.9)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives:5 "
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.79, y: self.size.height*0.9)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        
        
           startNewLevel()
        
        
        
    
        
            
    }
    
    func LoseAlife (){
        
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp,scaleDown])
        livesLabel.run(scaleSequence)
        
        
        
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
         
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
             
            
        }
        
        else{
            
            body1 = contact.bodyB
            body2 = contact.bodyA
            
        }
        if body1.categoryBitMask == PhysicsCategories.player && body2.categoryBitMask == PhysicsCategories.Enemy{
            
            
            if body1.node != nil {
            spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if body2.node != nil{
            spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            
        }
        
        
        func addScore() {
            gameScore += 1
            scoreLabel.text = "Score:\(gameScore)"
            
            if gameScore == 10 || gameScore == 25 || gameScore == 50{
                startNewLevel()
            }
            
        }
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy{
            
        
      addScore()
            
           
            
            
            if body2.node != nil{
            spawnExplosion(spawnPosition: body2.node!.position)
                
                
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
        }
        
        
    }
    
    func spawnExplosion(spawnPosition:CGPoint){
        
        let explosion = SKSpriteNode(imageNamed: "blood")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1,duration: 0.1)
        let fadeOut = SKAction.fadeIn(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
        
        
    }
    
   
    
       
        func startNewLevel(){
               
            levelNumber += 1
            if (self.action(forKey:"spawningEnemies") != nil){
                
                self.removeAction(forKey: "spawningEnemies")
            }
            
            var levelDuration = NSTimeIntervalSince1970
            
            switch levelNumber {
            case 1:levelDuration = 1.2
            case 2:levelDuration = 1
            case 3:levelDuration = 0.8
            case 4:levelDuration = 0.5
                
            default:
                levelDuration = 0.5
                print("cannot find level info")
                
            
                
                
            }
            
            
               
               let spawn  = SKAction.run(spawnEnemy)
               let waitToSpawn = SKAction.wait(forDuration:1)
               let spawnSequence = SKAction.sequence([ waitToSpawn, spawn])
               let spawnForever = SKAction.repeatForever(spawnSequence)
               self.run(spawnForever , withKey: "spawningEnemies")
           }
    
    
               
        
    
    
    func firebullet(){
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(0.3)
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        bullet.position = player.position
        bullet.zPosition = 1
        self.addChild(bullet)
         
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        
        let bulletSequence = SKAction.sequence( [bulletSound,moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
   
    func spawnEnemy(){
        
        let randomXStart = random(min: gamearea.minX, max:gamearea.maxX)
        let randomXEnd = random(min: gamearea.minX ,max: gamearea.maxX )
        
        let startPoint = CGPoint (x: randomXStart, y:self.size.height * 1.2 )
        let endPoint = CGPoint (x:randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "Monkey-1" )
        enemy.setScale(0.8)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.player
        
        self.addChild(enemy)
        
        
        let moveEnemy = SKAction.move(to:endPoint, duration: 3)
        let deleteEnemy = SKAction.removeFromParent()
        let loseAlifeAction = SKAction.run(LoseAlife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseAlifeAction])
        enemy.run(enemySequence)
        
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRoatate = atan2(dy, dx)
        enemy.zRotation = amountToRoatate
    }
    
    
    
        
       
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        firebullet()
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch:AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountdDragged = pointOfTouch.x - previousPointOfTouch.x
            player.position.x += amountdDragged
            
            if player.position.x > gamearea.maxX - player.size.width/2{
                player.position.x = gamearea.maxX - player.size.width/2
                
                
                
            }
            
            
            if player.position.x < gamearea.minX + player.size.width/2{
                player.position.x = gamearea.maxX + player.size.width/2 
            }
            
        }
    }
}
            
            
            
        
    




