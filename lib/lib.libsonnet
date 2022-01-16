local k = import 'github.com/jsonnet-libs/k8s-alpha/1.19/main.libsonnet';
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
  podman_build_job(
    image_name,
    containerfile,
    namespace='default',
    uid=1000,
    image_push_secret='image-pull-secret',
    builder_image='quay.io/podman/stable'
  ): {
    local job_name = 'build-' + std.md5(image_name),  // FIXME: Something that makes this more human-readible
    podman_local_volume::
      k.core.v1.volume.fromHostPath('podman-local', '/tmp/podman-containers'),
    tls_certs_volume::
      k.core.v1.volume.fromHostPath('tls-certs', '/etc/ssl/certs'),
    image_push_secret_volume::
      k.core.v1.volume.fromSecret('image-push-secret', image_push_secret) +
      k.core.v1.volume.secret.withItems([{ key: '.dockerconfigjson', path: 'config.json' }]),
    podman_container:: k.core.v1.container.new('builder', 'quay.io/podman/stable') +
                       k.core.v1.container.securityContext.withRunAsUser(uid) +
                       k.core.v1.container.resources.withLimits({ 'github.com/fuse': '1' }) +
                       k.core.v1.container.withArgs([
                         '/bin/bash',
                         '-xeuo',
                         'pipefail',
                         '-c',
                         |||
                           mkdir /tmp/context
                           echo %(containerfile)s > /tmp/context/Containerfile
                           podman build --isolation chroot -t "%(image_name)s" /tmp/context
                           podman push "%(image_name)s"
                         ||| % { image_name: image_name, containerfile: std.escapeStringBash(std.join('\n', containerfile)) },
                       ]) +
                       k.core.v1.container.withVolumeMounts([
                         k.core.v1.volumeMount.new(self.podman_local_volume.name, '/home/podman/.local/share/containers'),
                         k.core.v1.volumeMount.new(self.tls_certs_volume.name, '/etc/ssl/certs', readOnly=true),
                         k.core.v1.volumeMount.new(self.image_push_secret_volume.name, '/home/podman/.docker', readOnly=true),
                       ]),
    podman_build_job:
      k.batch.v1.job.new(job_name) +
      k.batch.v1.job.metadata.withNamespace(namespace) +
      k.batch.v1.job.spec.template.metadata.withAnnotations({
        ['container.apparmor.security.beta.kubernetes.io/' + self.podman_container.name]: 'unconfined',
      }) +
      k.batch.v1.job.spec.template.spec.withRestartPolicy('OnFailure') +
      k.batch.v1.job.spec.template.spec.withVolumes([
        self.podman_local_volume,
        self.tls_certs_volume,
        self.image_push_secret_volume,
      ]) +
      k.batch.v1.job.spec.template.spec.withContainers(self.podman_container),
  },
}
