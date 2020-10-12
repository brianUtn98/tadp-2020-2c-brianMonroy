name := "TADP Draw TP"

version := "1.0.0"

organization := "edu.ar.utn.tadp"

scalaVersion := "2.13.2"

resolvers += "Artima Maven Repository" at "https://repo.artima.com/releases"
resolvers += Resolver.sonatypeRepo("snapshots")

scalacOptions ++= Seq("-unchecked", "-deprecation", "-Xcheckinit", "-encoding", "utf8", "-feature")

// set the main class for 'sbt run'
mainClass in(Compile, run) := Some("tadp.drawing.TADPDrawingApp.scala")

// Determine OS version of JavaFX binariess
lazy val osName = System.getProperty("os.name") match {
  case n if n.startsWith("Linux") => "linux"
  case n if n.startsWith("Mac") => "mac"
  case n if n.startsWith("Windows") => "win"
  case _ => throw new Exception("Unknown platform!")
}

libraryDependencies ++= Seq(
  "org.scalatest" %% "scalatest" % "3.2.0" % "test",
  "org.scalactic" %% "scalactic" % "3.2.0",
  "org.scalafx" %% "scalafx" % "14-R19"
)

// Add JavaFX dependencies
lazy val javaFXModules = Seq("base", "controls", "fxml", "graphics", "media", "swing", "web")
libraryDependencies ++= javaFXModules.map(m =>
  "org.openjfx" % s"javafx-$m" % "14.0.1" classifier osName
)

// Fork a new JVM for 'run' and 'test:run', to avoid JavaFX double initialization problems
fork := true