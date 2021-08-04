//
// GridLight.swift
// GENERATED CONTENT. DO NOT EDIT.
//  

import Foundation
import RealityKit
import simd
import Combine

@available(iOS 13.0, macOS 10.15, *)
public enum GridLight {

    public enum LoadRealityFileError: Error {
        case fileNotFound(String)
    }

    private static var streams = [Combine.AnyCancellable]()

    public static func loadScene() throws -> GridLight.Scene {
        guard let realityFileURL = Foundation.Bundle(for: GridLight.Scene.self).url(forResource: "GridLight", withExtension: "reality") else {
            throw GridLight.LoadRealityFileError.fileNotFound("GridLight.reality")
        }

        let realityFileSceneURL = realityFileURL.appendingPathComponent("Scene", isDirectory: false)
        let anchorEntity = try GridLight.Scene.loadAnchor(contentsOf: realityFileSceneURL)
        return createScene(from: anchorEntity)
    }

    public static func loadSceneAsync(completion: @escaping (Swift.Result<GridLight.Scene, Swift.Error>) -> Void) {
        guard let realityFileURL = Foundation.Bundle(for: GridLight.Scene.self).url(forResource: "GridLight", withExtension: "reality") else {
            completion(.failure(GridLight.LoadRealityFileError.fileNotFound("GridLight.reality")))
            return
        }

        var cancellable: Combine.AnyCancellable?
        let realityFileSceneURL = realityFileURL.appendingPathComponent("Scene", isDirectory: false)
        let loadRequest = GridLight.Scene.loadAnchorAsync(contentsOf: realityFileSceneURL)
        cancellable = loadRequest.sink(receiveCompletion: { loadCompletion in
            if case let .failure(error) = loadCompletion {
                completion(.failure(error))
            }
            streams.removeAll { $0 === cancellable }
        }, receiveValue: { entity in
            completion(.success(GridLight.createScene(from: entity)))
        })
        cancellable?.store(in: &streams)
    }

    private static func createScene(from anchorEntity: RealityKit.AnchorEntity) -> GridLight.Scene {
        let scene = GridLight.Scene()
        scene.anchoring = anchorEntity.anchoring
        scene.addChild(anchorEntity)
        return scene
    }

    public class Scene: RealityKit.Entity, RealityKit.HasAnchoring {

    }

}
