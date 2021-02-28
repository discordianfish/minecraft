{
  _config+:: {
    image_build_run+:: [
      "curl -Lsfo plugins/Geyser.jar 'https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/628/artifact/bootstrap/spigot/target/Geyser-Spigot.jar'",
    ]
  }
}
