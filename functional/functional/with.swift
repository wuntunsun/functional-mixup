//
//  with.swift
//  functional
//
//  Created by Robert Norris on 31.01.21.
//

import Foundation
import UIKit



public func with<A>(_ a: (@escaping (A)->())->()
    , completion: @escaping ((A))->())->() {

    a { _a in

        completion((_a))
    }
}

public func with<A,B>(_ a: (@escaping (A)->())->()
    , _ b: @escaping (@escaping (B)->())->()
    , completion: @escaping ((A, B))->())->() {

    with(a) { _a in

        b { _b in

            completion((_a, _b))
        }
    }
}

public func with<A,B,C>(_ a: (@escaping (A)->())->()
    , _ b: @escaping (@escaping (B)->())->()
    , _ c: @escaping (@escaping (C)->())->()
    , completion: @escaping ((A, B, C))->())->() {

    with(a, b) { (_a, _b) in

        c { _c in

            completion((_a, _b, _c))
        }
    }
}

public func with<A,B,C,D>(_ a: (@escaping (A)->())->()
    , _ b: @escaping (@escaping (B)->())->()
    , _ c: @escaping (@escaping (C)->())->()
    , _ d: @escaping (@escaping (D)->())->()
    , completion: @escaping ((A, B, C, D))->())->() {

    with(a, b, c) { (_a, _b, _c) in

        d { _d in

            completion((_a, _b, _c, _d))
        }
    }
}



