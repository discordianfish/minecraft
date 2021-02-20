{
  _config+:: {
    image_build_run+:: [
      "curl -Lsfo plugins/GriefPrevention.jar 'https://ci.appveyor.com/api/buildjobs/w2ujrjnh8ty8oofs/artifacts/target%2FGriefPrevention.jar'",
    ]
  }
}
