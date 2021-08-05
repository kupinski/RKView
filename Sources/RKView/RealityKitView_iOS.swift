import Foundation
import SwiftUI
import RealityKit
//
//
#if os(iOS)
//struct newView: UIViewRepresentable {
//  @State var direction = ""
//
//  typealias UIViewType = UIView
//  var v = UIView()
//
//  func updateUIView(_ uiView: UIView, context: Context) {
//    v.backgroundColor = UIColor.yellow
//  }
//  
//  func makeUIView(context: Context) -> UIView {
//      let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(RKView.handleTap(sender:)))
////    let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(sender:)))
//      let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(RKView.handlePinch(sender:)))
//      let leftSwipe = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(RKView.handleSwipe(sender:)))
//    leftSwipe.direction = .left
//    let rightSwipe = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(RKView.handleSwipe(sender:)))
//    rightSwipe.direction = .right
//    
//    
////    v.addGestureRecognizer(panGesture)
//    v.addGestureRecognizer(pinchGesture)
//    v.addGestureRecognizer(tapGesture)
//    v.addGestureRecognizer(leftSwipe)
//    v.addGestureRecognizer(rightSwipe)
//    return v
//    }
//    
////  func makeCoordinator() -> newView.Coordinator {
////    Coordinator(v)
////  }
//  
//}
//
@available(iOS 13, *)


public struct RealityKitView: UIViewRepresentable {
    
    public typealias UIViewType = RKView
    public var rkView: RKView

    
    public class Coordinator: NSObject {
        public var rkView: RKView
        
        public init(rkView: RKView) {
            self.rkView = rkView
        }
        
        @objc func triggerTouchAction(gestureReconizer: UITapGestureRecognizer) {
            print("Hello, tap!")
        }

    }
    public func makeUIView(context: Context) -> RKView {
        let view = RKView(frame: .zero)
        let gRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.triggerTouchAction(gestureReconizer:)))
        view.addGestureRecognizer(gRecognizer)

        return(view)
    }
    
    public func updateUIView(_ uiView: RKView, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        return(Coordinator(rkView: rkView))
    }
}
    
    

@available(iOS 13, *)
public class RKViewController: UIViewController {
    public var rkView: RKView
    
    public init(withRKView: RKView) {
        rkView = withRKView
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
        
        rkView.radius = 2.0 * Double(boundingBox.boundingRadius)
        rkView.lookAt = boundingBox.center
        rkView.dragFactor = 0.01 / 2.0 * rkView.radius
        rkView.zoomFactor = 1.0 / 2.0 * rkView.radius
        
        rkView.look()
    }
    
}
#endif
