//: Playground - noun: a place where people can play

import UIKit


let xs: [Int?] = [1,nil,3,4,nil,6,7]

for case .Some(let num) in xs {
    print(num)
}

let otherxs = xs.flatMap {
    $0
}

otherxs

extension Array{
    
    typealias item = Element
    var clean: [Element!] {
        
        return self.flatMap{ $0 }
    }
    
}


let cleanxs = xs.clean


cleanxs