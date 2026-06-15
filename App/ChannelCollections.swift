import Foundation

extension Array {
  func index(afterWrapping index: Index) -> Index {
    let next = self.index(after: index)
    return next == endIndex ? startIndex : next
  }

  func index(beforeWrapping index: Index) -> Index {
    index == startIndex ? self.index(before: endIndex) : self.index(before: index)
  }
}

extension Array where Element == Channel {
  func uniquedByID() -> [Channel] {
    var seenIDs = Set<String>()
    return filter { channel in
      seenIDs.insert(channel.id).inserted
    }
  }
}
