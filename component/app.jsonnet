local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.prom_label_proxy;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('prom-label-proxy', params.namespace);

local appPath =
  local project = std.get(std.get(app, 'spec', {}), 'project', 'syn');
  if project == 'syn' then 'apps' else 'apps-%s' % project;

{
  ['%s/prom-label-proxy' % appPath]: app,
}
