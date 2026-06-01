# Phase 7 — WAF (Coraza / OWASP CRS) on the EKS hub. The coraza plugin is
# registered on the hub Traefik (main.tf custom_plugins); this Middleware applies
# the OWASP core rules (SQLi / XSS / scanner detection -> 403). A protected route
# at waf.<domain> proves it: a malicious request is blocked, a benign one passes.
# (Also demonstrates the "NGINX-mode security" story — the same WAF middleware
# can guard routes served via the kubernetesIngressNGINX provider.)

resource "kubectl_manifest" "coraza_waf" {
  provider   = kubectl.eks
  depends_on = [module.traefik]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata   = { name = "coraza-waf", namespace = local.hub_traefik_ns }
    spec = {
      plugin = {
        coraza = {
          directives = [
            "SecRuleEngine On",
            "SecRequestBodyAccess On",
            "SecResponseBodyAccess Off",
            "SecRule ARGS \"@detectSQLi\" \"id:942100,phase:2,deny,status:403,msg:'SQL Injection Detected',log,tag:attack-sqli\"",
            "SecRule ARGS \"@detectXSS\" \"id:941100,phase:2,deny,status:403,msg:'XSS Attack Detected',log,tag:attack-xss\"",
            "SecRule REQUEST_HEADERS:User-Agent \"@contains sqlmap\" \"id:913100,phase:1,deny,status:403,msg:'Automated Scanner Blocked',log,tag:attack-scanner\"",
          ]
          responseCheck = false
        }
      }
    }
  })
}

# A WAF-protected whoami route (waf.<domain>): SQLi/XSS -> 403, benign -> 200.
resource "kubectl_manifest" "waf_route" {
  provider   = kubectl.eks
  depends_on = [kubectl_manifest.coraza_waf, module.whoami]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata   = { name = "waf-whoami", namespace = local.hub_traefik_ns }
    spec = {
      entryPoints = ["websecure"]
      routes = [{
        kind        = "Rule"
        match       = "Host(`waf.${var.domain}`)"
        middlewares = [{ name = "coraza-waf" }]
        services    = [{ name = "whoami-svc", port = 80 }]
      }]
    }
  })
}
