//
//  UITableView+ReuseIdentifierProtocol.swift
//  R.swift Library
//
//  Created by Mathijs Kadijk on 06-12-15.
//  From: https://github.com/mac-cain13/R.swift.Library
//  License: MIT License
//


#if os(iOS) || os(tvOS)
import UIKit


extension UITableView {

    /**
     Register a `R.nib.*` containing a cell with the table view under it's contained identifier.

     - parameter resource: A nib resource (`R.nib.*`) containing a table view cell that has a reuse identifier
     */
    public func register<Resource: NibReferenceContainer & ReuseIdentifierContainer>(_ resource: Resource) where Resource.Reusable: UITableViewCell {
        register(UINib(resource: resource), forCellReuseIdentifier: resource.identifier)
    }

    /**
     Register a `R.reuseIdentifier.*` containing a cell with the table view under it's contained identifier.

     - parameter resource: A reuse identifier
     */
    public func register<Resource: ReuseIdentifierContainer>(_ resource: Resource) where Resource.Reusable: UITableViewCell {
        register(Resource.Reusable.self, forCellReuseIdentifier: resource.identifier)
    }

    /**
     Register a `R.nib.*` containing a header or footer with the table view under it's contained identifier.

     - parameter resource: A nib resource (`R.nib.*`) containing a view that has a reuse identifier
     */
    public func registerHeaderFooterView<Resource: NibReferenceContainer & ReuseIdentifierContainer>(_ resource: Resource) where Resource.Reusable: UIView {
        register(UINib(resource: resource), forHeaderFooterViewReuseIdentifier: resource.identifier)
    }

    /**
     Register a `R.reuseIdentifier.*` containing a header or footer with the table view under it's contained identifier.

     - parameter resource: A reuse identifier
     */
    public func registerHeaderFooterView<Resource: ReuseIdentifierContainer>(_ resource: Resource) where Resource.Reusable: UITableViewHeaderFooterView {
        register(Resource.Reusable.self, forHeaderFooterViewReuseIdentifier: resource.identifier)
    }

    /**
     Returns a typed reusable table-view cell object for the specified reuse identifier and adds it to the table.

     - parameter identifier: A `R.reuseIdentifier.*` value identifying the cell object to be reused.
     - parameter indexPath: The index path specifying the location of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the index path to perform additional configuration based on the cell’s position in the table view.

     - returns: The UITableViewCell subclass with the associated reuse identifier or nil if it couldn't be casted correctly.

     - precondition: You must register a class or nib file using the registerNib: or registerClass:forCellReuseIdentifier: method before calling this method.
     */
    public func dequeueReusableCell<Identifier: ReuseIdentifierContainer>(withIdentifier identifier: Identifier, for indexPath: IndexPath) -> Identifier.Reusable? where Identifier.Reusable: UITableViewCell {
        dequeueReusableCell(withIdentifier: identifier.identifier, for: indexPath) as? Identifier.Reusable
    }


    /**
     Returns a typed reusable header or footer view located by its identifier.

     - parameter identifier: A `R.reuseIdentifier.*` value identifying the header or footer view to be reused.

     - returns: A UITableViewHeaderFooterView object with the associated identifier or nil if no such object exists in the reusable view queue or if it couldn't be cast correctly.
     */
    public func dequeueReusableHeaderFooterView<Identifier: ReuseIdentifierContainer>(withIdentifier identifier: Identifier) -> Identifier.Reusable? where Identifier.Reusable: UITableViewHeaderFooterView {
        dequeueReusableHeaderFooterView(withIdentifier: identifier.identifier) as? Identifier.Reusable
    }
}


extension UICollectionView {

    /**
     Register a `R.nib.*` for use in creating new collection view cells.

     - parameter resource: A nib resource (`R.nib.*`) containing a object of type UICollectionViewCell that has a reuse identifier
     */
    public func register<Resource: NibReferenceContainer & ReuseIdentifierContainer>(_ resource: Resource) where Resource.Reusable: UICollectionViewCell {
        register(UINib(resource: resource), forCellWithReuseIdentifier: resource.identifier)
    }

    /**
     Register a `R.reuseIdentifier.*` for use in creating new collection view cells.

     - parameter resource: A reuse identifier
     */
    public func register<Resource: ReuseIdentifierContainer>(_ resource: Resource) where Resource.Reusable: UICollectionViewCell {
        register(Resource.Reusable.self, forCellWithReuseIdentifier: resource.identifier)
    }

    /**
     Register a `R.nib.*` for use in creating supplementary views for the collection view.

     - parameter resource: A nib resource (`R.nib.*`) containing a object of type UICollectionReusableView. that has a reuse identifier
     */
    public func register<Resource: NibReferenceContainer & ReuseIdentifierContainer>(_ resource: Resource, forSupplementaryViewOfKind kind: String) where Resource.Reusable: UICollectionReusableView {
        register(UINib(resource: resource), forSupplementaryViewOfKind: kind, withReuseIdentifier: resource.identifier)
    }

    /**
     Register a `R.reuseIdentfier.*` for use in creating supplementary views for the collection view.

     - parameter resource: A reuseIdentifier
     */
    public func register<Resource: ReuseIdentifierContainer>(_ resource: Resource, forSupplementaryViewOfKind kind: String) where Resource.Reusable: UICollectionReusableView {
        register(Resource.Reusable.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: resource.identifier)
    }

    /**
     Returns a typed reusable cell object located by its identifier

     - parameter identifier: The `R.reuseIdentifier.*` value for the specified cell.
     - parameter indexPath: The index path specifying the location of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the index path to perform additional configuration based on the cell’s position in the collection view.

     - returns: A subclass of UICollectionReusableView or nil if the cast fails.
     */
    public func dequeueReusableCell<Identifier: ReuseIdentifierContainer>(withReuseIdentifier identifier: Identifier, for indexPath: IndexPath) -> Identifier.Reusable? where Identifier.Reusable: UICollectionReusableView {
        dequeueReusableCell(withReuseIdentifier: identifier.identifier, for: indexPath) as? Identifier.Reusable
    }

    /**
     Returns a typed reusable supplementary view located by its identifier and kind.

     - parameter elementKind: The kind of supplementary view to retrieve. This value is defined by the layout object.
     - parameter identifier: The `R.reuseIdentifier.*` value for the specified view.
     - parameter indexPath: The index path specifying the location of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the index path to perform additional configuration based on the cell’s position in the collection view.

     - returns: A subclass of UICollectionReusableView or nil if the cast fails.
     */
    public func dequeueReusableSupplementaryView<Identifier: ReuseIdentifierContainer>(ofKind elementKind: String, withReuseIdentifier identifier: Identifier, for indexPath: IndexPath) -> Identifier.Reusable? where Identifier.Reusable: UICollectionReusableView {
        dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: identifier.identifier, for: indexPath) as? Identifier.Reusable
    }

}

#endif
