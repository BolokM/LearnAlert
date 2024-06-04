//
//  TimerManager.swift
//  LearnAlert
//
//  Created by Blake Miller on 4/3/24.
//

import Foundation

class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval? = nil
    var timer: Timer?

    func startTimer(interval: TimeInterval, selectedInterval: TimeInterval) {
        stopTimer()
    

        timeRemaining = interval

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                if let remaining = self?.timeRemaining, remaining > 0 {
                    self?.timeRemaining = remaining - 1
                } else {
                    self?.timeRemaining = selectedInterval  // Reset for the next cycle
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = nil
    }
}
