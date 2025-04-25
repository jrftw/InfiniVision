import Foundation
import AVFoundation
import Network

class AudioService: NSObject, ObservableObject {
    static let shared = AudioService()
    
    private var audioEngine: AVAudioEngine
    private var audioPlayer: AVAudioPlayerNode
    private var audioFormat: AVAudioFormat
    private var connection: NWConnection?
    private var isStreaming = false
    
    @Published var isConnected = false
    @Published var isMuted = false
    
    private override init() {
        audioEngine = AVAudioEngine()
        audioPlayer = AVAudioPlayerNode()
        audioFormat = AVAudioFormat(commonFormat: .pcmFloat32,
                                  sampleRate: 44100,
                                  channels: 2,
                                  interleaved: true)!
        
        super.init()
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        audioEngine.attach(audioPlayer)
        audioEngine.connect(audioPlayer, to: audioEngine.mainMixerNode, format: audioFormat)
        
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func connect(to host: String, port: UInt16) {
        let hostEndpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(host),
                                             port: NWEndpoint.Port(integerLiteral: port))
        
        connection = NWConnection(to: hostEndpoint, using: .tcp)
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.isConnected = true
                    self?.startStreaming()
                case .failed(let error):
                    print("Connection failed: \(error)")
                    self?.isConnected = false
                case .cancelled:
                    self?.isConnected = false
                default:
                    break
                }
            }
        }
        
        connection?.start(queue: .main)
    }
    
    private func startStreaming() {
        guard !isStreaming else { return }
        isStreaming = true
        
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            if let data = data {
                self?.processAudioData(data)
            }
            
            if isComplete || error != nil {
                self?.isStreaming = false
                self?.isConnected = false
            } else {
                self?.startStreaming()
            }
        }
    }
    
    private func processAudioData(_ data: Data) {
        guard !isMuted else { return }
        
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat,
                                    frameCapacity: AVAudioFrameCount(data.count / audioFormat.streamDescription.pointee.mBytesPerFrame))!
        
        data.withUnsafeBytes { ptr in
            let audioBuffer = buffer.audioBufferList.pointee.mBuffers
            audioBuffer.mData?.copyMemory(from: ptr.baseAddress!, byteCount: data.count)
            audioBuffer.mDataByteSize = UInt32(data.count)
            buffer.frameLength = AVAudioFrameCount(data.count / audioFormat.streamDescription.pointee.mBytesPerFrame)
        }
        
        audioPlayer.scheduleBuffer(buffer, completionHandler: nil)
        if !audioPlayer.isPlaying {
            audioPlayer.play()
        }
    }
    
    func disconnect() {
        connection?.cancel()
        connection = nil
        isConnected = false
        isStreaming = false
        audioPlayer.stop()
    }
    
    func toggleMute() {
        isMuted.toggle()
        if isMuted {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
    }
} 