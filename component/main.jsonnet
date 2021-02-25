local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();

local params = inv.parameters.prom_label_proxy;
local instance = inv.parameters._instance;

local labels = {
  'app.kubernetes.io/name': 'prom-label-proxy',
  'app.kubernetes.io/instance': instance,
  'app.kubernetes.io/managed-by': 'syn',
};

{
  deployment: kube.Deployment(instance) {
    metadata+: {
      namespace: params.namespace,
      labels+: labels,
    },
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            proxy: kube.Container('proxy') {
              local image = params.images['prom-label-proxy'],
              image: image.registry + '/' + image.image + ':' + image.tag,
              args: [
                '--insecure-listen-address=:8080',
                '--label=' + params.label,
                '--upstream=' + params.upstream,
              ],
              ports_+: {
                http: {
                  containerPort: 8080,
                },
              },
              resources+: params.resources,
            },
          },
          securityContext: {
            runAsUser: 10001,
          },
        },
      },
    },
  },
  service: kube.Service(instance) {
    metadata+: {
      namespace: params.namespace,
      labels+: labels,
    },
    target_pod: $.deployment.spec.template,
  },
  [if params.ingress.host != null then 'ingress']: kube.Ingress(instance) {
    metadata+: {
      namespace: params.namespace,
      annotations+: params.ingress.annotations,
      labels+: labels,
    },
    spec: {
      rules: [ {
        host: params.ingress.host,
        http: {
          paths: [ {
            // To remove the path and forward all traffic to this one backend
            path:: '/',
            backend: $.service.name_port,
          } ],
        },
      } ],
      tls: [ {
        hosts: [ params.ingress.host ],
      } ],
    },
  },
}
