import PackageDescription

let package = Package(name: "AVCaches",
                      platforms: [.iOS(.v10)],
                      products: [.library(name: "AVCaches",
                                          targets: ["AVCaches"])],
                      targets: [.target(name: "AVCaches",
                                        path: "Source",
                                        exclude: ["Info.plist"])],
                      swiftLanguageVersions: [.v5])
