//
//  Organizations.swift
//  functional-mixup
//
//  Created by Robert Norris on 31.01.21.
//

import UIKit

import functional



struct OrganizationsDTO: Decodable {

    let results: [OrganizationDTO]

    static func withOrganizations (_ organizations: @escaping (Result<OrganizationsDTO, Error>) -> ()) {

        if let url = URL(string: "https://tools.cdc.gov/api/v2/resources/organizations") {

            let task = URLSession.shared.dataTask(with: url) { data, response, error in

                if let error = error {

                    return organizations(.failure(error))
                }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                do {

                    let dto = try decoder.decode(OrganizationsDTO.self, from: data ?? Data())
                    organizations(.success(dto))
                }
                catch let thrown {

                    organizations(.failure(thrown))
                }
            }
            task.resume()
        }
    }
}



struct OrganizationDTO: Decodable {

    let id: Int
    let name: String?
    let type: String? // "U.S. Federal Government"
    //"typeOther": null,
    let description: String? // "U.S. Federal Government"
    let address: String? // "Clifton Rd."
    //"addressContinued": null,
    let city: String? // "Atlanta"
    let stateProvince: String? // "GA"
    let postalCode: String? // "30333"
    let county: String? // "Fulton"
    let country: String? // "US"
}



protocol ExpressibleByDecodable {

    associatedtype DecodableType: Decodable
    associatedtype Failure: Error

    init(decodable value: Self.DecodableType)

//    static func with(_ source: @escaping (Result<Self, Failure>) -> ()
//                     , decodable: @escaping (Result<DecodableType, Failure>) -> ())

    // from Result public init(catching body: () throws -> Success)
    //static func map(_ transform: (DecodableType) -> Self) -> Self
}



extension ExpressibleByDecodable {

//    static func with(_ source: @escaping (Result<Self, Failure>) -> ()
//                     , decodable: @escaping (Result<DecodableType, Failure>) -> ()) {
//
//        decodable { result in
//
//
//        }
//    }

}




class Organizations: NSObject, UITableViewDataSource, ExpressibleByDecodable {

    typealias Failure = Error
    typealias DecodableType = OrganizationsDTO

    private let decodable: DecodableType

    required init(decodable: DecodableType) {

        self.decodable = decodable

        super.init()
    }

    static func withOrganizations (_ organizations: @escaping (Result<Organizations, Error>) -> ()) {

        with(OrganizationsDTO.withOrganizations) { result in

            organizations(result.map { Organizations(decodable: $0) })
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.decodable.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let tableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: String(describing: self))

        let organization = self.decodable.results[indexPath.row]

        tableViewCell.textLabel?.text = organization.name
        tableViewCell.detailTextLabel?.text = organization.description

        return tableViewCell
    }
}
