// swift-tools-version:5.2

import PackageDescription

let package = Package(
	name: "Alderis",
	platforms: [
		.iOS(.v12)
	],
	products: [
		.library(name: "Alderis", targets: ["Alderis"]),
	],
	targets: [
		.target(name: "Alderis", path: "Alderis")
	]
)
