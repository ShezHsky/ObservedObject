import Combine

protocol PipelineFactory {
    
    associatedtype Pipeline: Publisher where Pipeline.Failure == Never
    
    func makePipeline() -> Pipeline
    
}
