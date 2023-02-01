import RealityKit
import SwiftUI

private extension FloatingPoint {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(min(self, range.upperBound), range.lowerBound)
    }
}

/// An `RKView` is a RealityKit View that is NOT going to be used in Augmented Reality applications.  This view was created as a replacement for SceneKit views that has the .allowCameraControl property.  This currently doesn't exist in `ARView`.  In `RKView` a camera is created and it's placement and focus are based on the entities in the scene.
@available(iOS 13.0, macOS 10.15, *)
public class RKView : ARView {
    /// The AnchorEntity that holds the camera and the floor.  The camera needs to be in its own anchor separate from the rest of the scene.  This anchor is excluded from some of the calculations regarding the scene extent.
    public var excludedAnchor = AnchorEntity(world: [0, 0, 0])
    /// The camera entity
    public var cameraEntity = PerspectiveCamera()
    
    public var floorEntity = try! GridLight.loadScene()
    
    /// The point that the camera is looking at.  Starts at origin but is changed in viewDidLoad to the center of the scene
    public var lookAt = SIMD3<Float>(0.0, 0.0, 0.0)
    /// The distance from the center of focus to the camera.  Starts at 1.5m but is changed in viewDidLoad
    public var radius = 1.0
    /// The location of the camera. This is a computed property that utilizes, ``lookAt``, ``radius``, ``theta``, and ``phi``
    public var lookFrom: SIMD3<Float> {
        return lookAt + SIMD3<Float>(Float(radius * cos(phi) * sin(theta)),
                                     Float(radius * sin(phi)),
                                     Float(-radius * cos(phi) * cos(theta)))
    }
    /// The angle in the x-z-plane.  Ranges from 0 to 2π.  0 is in the positive z direction
    public var theta = 0.0
    /// The tilt of the camera.  0 is looking horizontal.  π/2 is looking down.  Ranges from -π/2 to π/2.
    public var phi = Angle(degrees: 15.0).radians
    
    /// Units are radians/pixel.  This controls how fast angles changes when the user modifies ``theta`` and ``phi`` using drag gestures
    public var angleFactor = 0.01
    
    /// Units are m/pixel.  This controls how fast the camera moves when the user pans/
    public var dragFactor = 0.01
    
    /// Units are m/pixel.  This controls how much the camera zooms when the user does a pinch control.
    public var zoomFactor = 1.0
    
    // Units are meters.  Starts out at 20 but is modified in viewDidLoad based on the scene.  This determine how far away from the primary scene you can move the camera.
    public var sceneRadius = 20.0
    
    public var showFloor: Bool = false {
        didSet {
            floorEntity.isEnabled = showFloor
        }
    }
    
    /// Create an RKView based on the provided frame.  Typically this is set to .zero and resized later
    /// - Parameter frame: Typically this is set to .zero and resized later
    public required init(frame: CGRect) {
        super.init(frame: frame)
        excludedAnchor.addChild(cameraEntity)
        excludedAnchor.addChild(floorEntity)
        
        cameraEntity.position = lookFrom
        cameraEntity.look(at: lookAt, from: lookFrom, relativeTo: nil)

        scene.addAnchor(excludedAnchor)
        
        guard let sky = try? EnvironmentResource.load(named: "ibl", in: Bundle.module) else {
            fatalError("Cannot load sky")
        }
        guard let lighting = try? EnvironmentResource.load(named: "ref", in: Bundle.module) else {
            fatalError("Cannot load sky")
        }

        self.environment.lighting.resource = lighting
        self.environment.background = .skybox(sky)
    }
    
    @MainActor @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func look(at: SIMD3<Float>? = nil, from: SIMD3<Float>? = nil) {
        cameraEntity.look(at: at ?? lookAt, from: from ?? lookFrom, relativeTo: nil)
    }
    
    #if os(macOS)
    public override func mouseDown(with event: NSEvent) {
    }
    
    public override func mouseDragged(with event: NSEvent) {
        theta += event.deltaX * angleFactor
        phi += event.deltaY * angleFactor
        phi = phi.clamped(to: (-Double.pi / 2.0 + 0.00001)...(Double.pi / 2.0 - 0.00001))

        cameraEntity.look(at: lookAt, from: lookFrom, relativeTo: nil)
    }
    
    public override func magnify(with event: NSEvent) {
        radius += event.magnification * -zoomFactor
        radius = radius.clamped(to: Double(Float.ulpOfOne)...sceneRadius)
        cameraEntity.look(at: lookAt, from: lookFrom, relativeTo: nil)
    }
    
    public override func scrollWheel(with event: NSEvent) {
        var deltaX = dragFactor * event.deltaX * cos(theta) * cos(phi)
        deltaX -= dragFactor * event.deltaY * sin(theta) * sin(phi)
        let deltaY = event.deltaY * dragFactor * cos(phi)
        var deltaZ = dragFactor * event.deltaX * sin(theta) * cos(phi)
        deltaZ += dragFactor * event.deltaY * cos(theta) * sin(phi)
        
        lookAt += SIMD3<Float>(Float(deltaX),
                               Float(deltaY),
                               Float(deltaZ))
        cameraEntity.look(at: lookAt, from: lookFrom, relativeTo: nil)
    }
    
    #elseif os(iOS)
    
//    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
//      let scale = sender.scale
//      print("scale \(scale)")
//    }
//
//    @objc func handleTap(sender: UITapGestureRecognizer) {
//      let location = sender.location(in: self)
//        print("tap \(location)")
//    }
//
//    @objc func handlePan(sender: UIPanGestureRecognizer) {
//
//      let translation = sender.translation(in: self)
//      let location = sender.location(in: self)
//
//      sender.setTranslation(.zero, in: self)
//        print("pan \(location) \(translation)")
//    }
//
//    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
//      if sender.direction == .left {
//        let location = sender.location(in: self)
//          print("left \(location)")
//      } else {
//        if sender.direction == .right {
//          let location = sender.location(in: self)
//            print("right \(location)")
//        }
//      }
//    }

    #endif
    
}

