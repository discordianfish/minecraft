{
  containerfile: import 'containerfile.libsonnet',
  render(site): {
    [path]: std.manifestYamlDoc(site[path])
    for path in std.objectFields(site)
  },

  build(site, prefix='manifests/'): {
    [prefix + app + '/' + manifest + '.yaml']: site[app][manifest]
    for app in std.objectFields(site)  // stack fields are apps
    for manifest in std.objectFields(site[app])  // app fields are manifests
  },
}
