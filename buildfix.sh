for path in ~/Library/Developer/Xcode/DerivedData/*/Build/Products/Debug/; do
    cp "$(xcode-select -p)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx/lib_InternalSwiftSyntaxParser.dylib" $path
done
