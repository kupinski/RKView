import Foundation
import SwiftUI
import RealityKit


#if os(macOS)
/// A SwiftUI View that controls an``RKView`` for viewing a RealityKit scene without any augmented reality applications and allowing for mouse or touch camera controls.
@available(macOS 10.15, *)
public struct RealityKitView : NSViewControllerRepresentable {
    /// The ``RKView`` to be displayed
    public var rkView: RKView
    
    public typealias NSViewControllerType = RKViewController
    
    public func makeNSViewController(context: NSViewControllerRepresentableContext<RealityKitView>) -> RKViewController {
        let viewController = RKViewController(withARView: rkView)
        
        return viewController
    }
    
    public func updateNSViewController(_ nsViewController: RKViewController, context: NSViewControllerRepresentableContext<RealityKitView>) {
    }
    
    public init(view: RKView) {
        self.rkView = view
    }
    
}

@available(macOS 10.15, *)
public class RKViewController: NSViewController {
    public var rkView: RKView
    
    public init(withARView: RKView) {
        rkView = withARView
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required public  init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func loadView() {
        self.view = rkView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Determine the bounding box of all the scenes currently in the rkView.  This excludes the floor if present.

        var boundingBox = BoundingBox()
        for anch in rkView.scene.anchors {
            if (anch != rkView.excludedAnchor) {
                boundingBox.formUnion(anch.visualBounds(recursive: true, relativeTo: nil, excludeInactive: true))
            }
        }
        
        if (boundingBox.boundingRadius != 0) {
            rkView.radius = 2.0 * Double(boundingBox.boundingRadius)
            rkView.lookAt = boundingBox.center
        }
        rkView.dragFactor = 0.01 / 2.0 * rkView.radius
        rkView.zoomFactor = 1.0 / 2.0 * rkView.radius
        
        rkView.look()
    }
    
}
#endif

