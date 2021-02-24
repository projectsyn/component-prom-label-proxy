local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.prom_label_proxy;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('prom-label-proxy', params.namespace);

{
  'prom-label-proxy': app,
}
