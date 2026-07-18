import SpriteKit

protocol FootbowlingSceneDelegate: AnyObject {
    func sceneDidShoot()
    func sceneDidFinish(defendersKnocked: Int, remainingDefenders: Int, completed: Bool)
}

final class GameScene: SKScene {
    weak var gameDelegate: FootbowlingSceneDelegate?
    private let level: GameLevel
    private let ball = SKShapeNode(circleOfRadius: 17)
    private let ballShadow = SKShapeNode(ellipseOf: CGSize(width: 48, height: 16))
    private let aimRing = SKShapeNode(circleOfRadius: 42)
    private let goal = SKShapeNode(rectOf: CGSize(width: 132, height: 42), cornerRadius: 10)
    private let pathNode = SKShapeNode()
    private let pathGlowNode = SKShapeNode()
    private var defenders: [SKShapeNode] = []
    private var points: [CGPoint] = []
    private var didFinish = false

    init(size: CGSize, level: GameLevel) {
        self.level = level
        super.init(size: size)
        scaleMode = .resizeFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = level.backgroundBottom.color
        physicsWorld.gravity = .zero
        detachReusableNodes()
        createField()
        createGoal()
        createDefenders()
        resetBall()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        detachReusableNodes()
        removeAllChildren()
        defenders.removeAll()
        didFinish = false
        createField()
        createGoal()
        createDefenders()
        resetBall()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !didFinish, let point = touches.first?.location(in: self), distance(point, ball.position) < 70 else { return }
        points = [ball.position]
        pathNode.removeFromParent()
        pathGlowNode.removeFromParent()
        pathGlowNode.strokeColor = UIColor.cyan.withAlphaComponent(0.36)
        pathGlowNode.lineWidth = 15
        pathGlowNode.lineCap = .round
        pathGlowNode.zPosition = 6
        pathNode.strokeColor = UIColor.white.withAlphaComponent(0.96)
        pathNode.lineWidth = 4
        pathNode.lineCap = .round
        pathNode.zPosition = 7
        aimRing.run(.fadeAlpha(to: 0.2, duration: 0.14))
        addChild(pathGlowNode)
        addChild(pathNode)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !points.isEmpty, let point = touches.first?.location(in: self) else { return }
        points.append(point)
        drawPath()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard points.count > 2 else { return }
        if let point = touches.first?.location(in: self) {
            points.append(point)
        }
        shoot()
    }

    private func createField() {
        let background = SKSpriteNode(texture: gradientTexture(size: size, top: level.backgroundTop.color, bottom: level.backgroundBottom.color))
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -8
        addChild(background)
        createCrowd()
        createLightBeams()
        createPitchLines()
        createStartZone()
        createCornerFlags()
    }

    private func createGoal() {
        goal.removeFromParent()
        goal.removeAllActions()
        goal.setScale(1)
        let glow = SKShapeNode(rectOf: CGSize(width: 186, height: 76), cornerRadius: 24)
        glow.position = CGPoint(x: size.width / 2, y: size.height - 88)
        glow.fillColor = UIColor.white.withAlphaComponent(0.08)
        glow.strokeColor = UIColor.white.withAlphaComponent(0.18)
        glow.lineWidth = 2
        glow.zPosition = 0
        addChild(glow)
        let shadow = SKShapeNode(rectOf: CGSize(width: 156, height: 56), cornerRadius: 16)
        shadow.position = CGPoint(x: size.width / 2, y: size.height - 82)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.22)
        shadow.strokeColor = .clear
        shadow.zPosition = 0
        addChild(shadow)
        goal.position = CGPoint(x: size.width / 2, y: size.height - 88)
        goal.strokeColor = .white
        goal.fillColor = UIColor.white.withAlphaComponent(0.14)
        goal.lineWidth = 5
        goal.zPosition = 2
        addChild(goal)
        let crossbar = SKShapeNode(rectOf: CGSize(width: 146, height: 6), cornerRadius: 3)
        crossbar.fillColor = UIColor.white.withAlphaComponent(0.92)
        crossbar.strokeColor = .clear
        crossbar.position = CGPoint(x: goal.position.x, y: goal.position.y + 24)
        crossbar.zPosition = 4
        addChild(crossbar)
        for side in [-1, 1] {
            let post = SKShapeNode(rectOf: CGSize(width: 7, height: 56), cornerRadius: 3.5)
            post.fillColor = UIColor.white.withAlphaComponent(0.92)
            post.strokeColor = .clear
            post.position = CGPoint(x: goal.position.x + CGFloat(side) * 72, y: goal.position.y - 2)
            post.zPosition = 4
            addChild(post)
        }
        for index in -2...2 {
            let vertical = SKShapeNode(rectOf: CGSize(width: 1.5, height: 38))
            vertical.fillColor = UIColor.white.withAlphaComponent(0.18)
            vertical.strokeColor = .clear
            vertical.position = CGPoint(x: goal.position.x + CGFloat(index) * 24, y: goal.position.y)
            vertical.zPosition = 3
            addChild(vertical)
        }
        for index in -1...1 {
            let horizontal = SKShapeNode(rectOf: CGSize(width: 124, height: 1.5))
            horizontal.fillColor = UIColor.white.withAlphaComponent(0.18)
            horizontal.strokeColor = .clear
            horizontal.position = CGPoint(x: goal.position.x, y: goal.position.y + CGFloat(index) * 13)
            horizontal.zPosition = 3
            addChild(horizontal)
        }
        let label = SKLabelNode(text: "GOAL")
        label.fontName = "Avenir-Black"
        label.fontSize = 16
        label.fontColor = .white
        label.position = CGPoint(x: goal.position.x, y: goal.position.y - 7)
        label.zPosition = 4
        addChild(label)
    }

    private func createDefenders() {
        let rows = max(2, Int(ceil(Double(level.defenders) / 4.0)))
        var created = 0
        for row in 0..<rows {
            let count = min(4, level.defenders - created)
            let spacing = size.width / CGFloat(count + 1)
            for column in 0..<count {
                let position = CGPoint(
                    x: spacing * CGFloat(column + 1) + CGFloat(row % 2) * 14,
                    y: size.height * 0.47 + CGFloat(row) * 58
                )
                let shadow = SKShapeNode(ellipseOf: CGSize(width: 38, height: 14))
                shadow.position = CGPoint(x: position.x + 4, y: position.y - 28)
                shadow.fillColor = UIColor.black.withAlphaComponent(0.24)
                shadow.strokeColor = .clear
                shadow.zPosition = 0
                addChild(shadow)
                let defender = SKShapeNode(rectOf: CGSize(width: 30, height: 52), cornerRadius: 11)
                defender.fillColor = UIColor(red: 1.0, green: 0.78, blue: 0.18, alpha: 1)
                defender.strokeColor = UIColor.white.withAlphaComponent(0.95)
                defender.lineWidth = 2
                defender.position = position
                defender.zPosition = 3
                defender.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 52))
                defender.physicsBody?.isDynamic = false
                defender.name = "defender"
                let topLight = SKShapeNode(ellipseOf: CGSize(width: 22, height: 10))
                topLight.fillColor = UIColor.white.withAlphaComponent(0.22)
                topLight.strokeColor = .clear
                topLight.position = CGPoint(x: -2, y: 16)
                topLight.zPosition = 2
                let stripe = SKShapeNode(rectOf: CGSize(width: 24, height: 8), cornerRadius: 4)
                stripe.fillColor = UIColor.white.withAlphaComponent(0.86)
                stripe.strokeColor = .clear
                stripe.position = CGPoint(x: 0, y: 10)
                stripe.zPosition = 1
                defender.addChild(topLight)
                defender.addChild(stripe)
                let idle = SKAction.sequence([
                    .moveBy(x: CGFloat(row % 2 == 0 ? 3 : -3), y: 0, duration: 0.7),
                    .moveBy(x: CGFloat(row % 2 == 0 ? -3 : 3), y: 0, duration: 0.7)
                ])
                defender.run(.repeatForever(idle))
                defenders.append(defender)
                addChild(defender)
                created += 1
            }
        }
    }

    private func resetBall() {
        ball.removeFromParent()
        ballShadow.removeFromParent()
        aimRing.removeFromParent()
        ball.removeAllActions()
        ballShadow.removeAllActions()
        aimRing.removeAllActions()
        ball.setScale(1)
        ball.position = CGPoint(x: size.width / 2, y: 82)
        ballShadow.position = CGPoint(x: ball.position.x + 4, y: ball.position.y - 22)
        ballShadow.fillColor = UIColor.black.withAlphaComponent(0.28)
        ballShadow.strokeColor = .clear
        ballShadow.zPosition = 4
        aimRing.position = ball.position
        aimRing.strokeColor = UIColor.white.withAlphaComponent(0.34)
        aimRing.lineWidth = 2
        aimRing.fillColor = UIColor.white.withAlphaComponent(0.045)
        aimRing.zPosition = 5
        ball.fillColor = .white
        ball.strokeColor = UIColor.black.withAlphaComponent(0.9)
        ball.lineWidth = 3
        ball.zPosition = 8
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 17)
        ball.physicsBody?.allowsRotation = true
        ball.physicsBody?.linearDamping = 0.2
        addChild(ballShadow)
        addChild(aimRing)
        addChild(ball)
        if ball.children.isEmpty {
            for index in 0..<5 {
                let patch = SKShapeNode(circleOfRadius: index == 0 ? 5 : 3.5)
                patch.fillColor = UIColor.black.withAlphaComponent(0.88)
                patch.strokeColor = .clear
                let angle = CGFloat(index) * .pi * 2 / 5
                patch.position = index == 0 ? .zero : CGPoint(x: cos(angle) * 10, y: sin(angle) * 10)
                patch.zPosition = 1
                ball.addChild(patch)
            }
        }
        let pulse = SKAction.sequence([.scale(to: 1.06, duration: 0.55), .scale(to: 1.0, duration: 0.55)])
        let ringPulse = SKAction.sequence([.scale(to: 1.18, duration: 0.65), .scale(to: 1.0, duration: 0.65)])
        ball.run(.repeatForever(pulse), withKey: "idlePulse")
        aimRing.run(.repeatForever(ringPulse), withKey: "ringPulse")
    }

    private func detachReusableNodes() {
        goal.removeFromParent()
        ball.removeFromParent()
        ballShadow.removeFromParent()
        aimRing.removeFromParent()
        pathNode.removeFromParent()
        pathGlowNode.removeFromParent()
    }

    private func drawPath() {
        let path = CGMutablePath()
        path.move(to: points[0])
        points.dropFirst().forEach { path.addLine(to: $0) }
        pathGlowNode.path = path
        pathNode.path = path
    }

    private func shoot() {
        didFinish = true
        gameDelegate?.sceneDidShoot()
        drawPath()
        let path = CGMutablePath()
        path.move(to: points[0])
        points.dropFirst().forEach { path.addLine(to: $0) }
        let action = SKAction.follow(path, asOffset: false, orientToPath: false, speed: 310)
        ball.removeAction(forKey: "idlePulse")
        ballShadow.run(.fadeOut(withDuration: 0.18))
        aimRing.run(.fadeOut(withDuration: 0.18))
        ball.run(action) { [weak self] in
            self?.resolveShot()
        }
    }

    private func resolveShot() {
        let knocked = defenders.filter { defender in
            points.contains { distance($0, defender.position) < 38 }
        }
        defenders.removeAll { defender in
            knocked.contains(defender)
        }
        knocked.forEach { defender in
            defender.run(.sequence([
                .group([.rotate(byAngle: .pi / 2, duration: 0.2), .fadeAlpha(to: 0.25, duration: 0.2)]),
                .removeFromParent()
            ]))
        }
        let finalPoint = points.last ?? ball.position
        let reachedGoal = points.contains { point in
            abs(point.x - goal.position.x) < 72 && abs(point.y - goal.position.y) < 42
        } || (abs(finalPoint.x - goal.position.x) < 72 && abs(finalPoint.y - goal.position.y) < 42)
        let completed = reachedGoal || defenders.isEmpty
        gameDelegate?.sceneDidFinish(defendersKnocked: knocked.count, remainingDefenders: defenders.count, completed: completed)
        if completed {
            goal.run(.sequence([.scale(to: 1.08, duration: 0.16), .scale(to: 1.0, duration: 0.16)]))
            createBurst(at: knocked.first?.position ?? goal.position, color: UIColor(red: 0.22, green: 1.0, blue: 0.55, alpha: 1))
        }
        pathNode.run(.fadeOut(withDuration: 0.4))
        pathGlowNode.run(.fadeOut(withDuration: 0.4))
        guard !completed else { return }
        run(.wait(forDuration: 0.9)) { [weak self] in
            self?.didFinish = false
            self?.resetBall()
        }
    }

    private func createCrowd() {
        let stand = SKShapeNode(rectOf: CGSize(width: size.width + 40, height: 74), cornerRadius: 18)
        stand.position = CGPoint(x: size.width / 2, y: size.height - 24)
        stand.fillColor = UIColor.black.withAlphaComponent(0.22)
        stand.strokeColor = UIColor.white.withAlphaComponent(0.08)
        stand.zPosition = -6
        addChild(stand)
        for index in 0..<18 {
            let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 2.2...4.2))
            dot.fillColor = UIColor.white.withAlphaComponent(CGFloat.random(in: 0.12...0.26))
            dot.strokeColor = .clear
            dot.position = CGPoint(x: CGFloat(index) * size.width / 17, y: size.height - CGFloat.random(in: 18...42))
            dot.zPosition = -5
            addChild(dot)
        }
    }

    private func createLightBeams() {
        for x in [size.width * 0.16, size.width * 0.84] {
            let beam = SKShapeNode(rectOf: CGSize(width: size.width * 0.55, height: size.height * 0.92), cornerRadius: 80)
            beam.position = CGPoint(x: x, y: size.height * 0.52)
            beam.fillColor = UIColor.white.withAlphaComponent(0.045)
            beam.strokeColor = .clear
            beam.zRotation = x < size.width / 2 ? -0.26 : 0.26
            beam.zPosition = -4
            addChild(beam)
        }
    }

    private func createPitchLines() {
        let border = SKShapeNode(rectOf: CGSize(width: size.width - 34, height: size.height - 130), cornerRadius: 24)
        border.position = CGPoint(x: size.width / 2, y: size.height / 2 - 16)
        border.strokeColor = UIColor.white.withAlphaComponent(0.32)
        border.lineWidth = 3
        border.fillColor = .clear
        border.zPosition = -1
        addChild(border)
        let centerLine = SKShapeNode(rectOf: CGSize(width: size.width - 54, height: 2))
        centerLine.position = CGPoint(x: size.width / 2, y: size.height * 0.42)
        centerLine.fillColor = UIColor.white.withAlphaComponent(0.18)
        centerLine.strokeColor = .clear
        centerLine.zPosition = -1
        addChild(centerLine)
        let centerCircle = SKShapeNode(circleOfRadius: 54)
        centerCircle.position = CGPoint(x: size.width / 2, y: size.height * 0.42)
        centerCircle.strokeColor = UIColor.white.withAlphaComponent(0.2)
        centerCircle.lineWidth = 2
        centerCircle.fillColor = .clear
        centerCircle.zPosition = -1
        addChild(centerCircle)
        for index in 0..<9 {
            let lane = SKShapeNode(rectOf: CGSize(width: size.width - 58, height: 1))
            lane.position = CGPoint(x: size.width / 2, y: CGFloat(index + 1) * size.height / 10)
            lane.fillColor = UIColor.white.withAlphaComponent(index % 2 == 0 ? 0.06 : 0.025)
            lane.strokeColor = .clear
            lane.zPosition = -2
            addChild(lane)
        }
    }

    private func createStartZone() {
        let base = CGPoint(x: size.width / 2, y: 82)
        let pad = SKShapeNode(ellipseOf: CGSize(width: 152, height: 62))
        pad.position = CGPoint(x: base.x, y: base.y - 6)
        pad.fillColor = UIColor.black.withAlphaComponent(0.16)
        pad.strokeColor = UIColor.white.withAlphaComponent(0.24)
        pad.lineWidth = 2
        pad.zPosition = 1
        addChild(pad)
        for index in 0..<3 {
            let ring = SKShapeNode(ellipseOf: CGSize(width: 88 + index * 28, height: 32 + index * 12))
            ring.position = pad.position
            ring.strokeColor = UIColor.white.withAlphaComponent(CGFloat(0.22 - Double(index) * 0.045))
            ring.lineWidth = 1.4
            ring.fillColor = .clear
            ring.zPosition = 2
            addChild(ring)
        }
        let label = SKLabelNode(text: "DRAG TO CURVE")
        label.fontName = "Avenir-Black"
        label.fontSize = 11
        label.fontColor = UIColor.white.withAlphaComponent(0.62)
        label.position = CGPoint(x: base.x, y: base.y - 52)
        label.zPosition = 3
        addChild(label)
    }

    private func createCornerFlags() {
        for x in [CGFloat(30), size.width - 30] {
            let pole = SKShapeNode(rectOf: CGSize(width: 3, height: 42), cornerRadius: 1.5)
            pole.position = CGPoint(x: x, y: size.height - 134)
            pole.fillColor = UIColor.white.withAlphaComponent(0.62)
            pole.strokeColor = .clear
            pole.zPosition = 1
            addChild(pole)
            let flagPath = CGMutablePath()
            flagPath.move(to: .zero)
            flagPath.addLine(to: CGPoint(x: x < size.width / 2 ? 22 : -22, y: -7))
            flagPath.addLine(to: CGPoint(x: 0, y: -14))
            flagPath.closeSubpath()
            let flag = SKShapeNode(path: flagPath)
            flag.fillColor = UIColor(red: 0.2, green: 1.0, blue: 0.58, alpha: 0.9)
            flag.strokeColor = .clear
            flag.position = CGPoint(x: x, y: size.height - 112)
            flag.zPosition = 2
            addChild(flag)
        }
    }

    private func createBurst(at position: CGPoint, color: UIColor) {
        for index in 0..<14 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = color.withAlphaComponent(0.9)
            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = 12
            addChild(particle)
            let angle = CGFloat(index) * .pi * 2 / 14
            let target = CGPoint(x: position.x + cos(angle) * 58, y: position.y + sin(angle) * 58)
            particle.run(.sequence([.group([.move(to: target, duration: 0.42), .fadeOut(withDuration: 0.42)]), .removeFromParent()]))
        }
    }
}

private func distance(_ first: CGPoint, _ second: CGPoint) -> CGFloat {
    hypot(first.x - second.x, first.y - second.y)
}

private func gradientTexture(size: CGSize, top: UIColor, bottom: UIColor) -> SKTexture {
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { context in
        let colors = [top.cgColor, bottom.cgColor] as CFArray
        let locations: [CGFloat] = [0, 1]
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: locations) else { return }
        context.cgContext.drawLinearGradient(
            gradient,
            start: CGPoint(x: size.width / 2, y: 0),
            end: CGPoint(x: size.width / 2, y: size.height),
            options: []
        )
    }
    return SKTexture(image: image)
}
