import yaml

# Define the validation function
validate = lambda item {
    if item.kind == "Application" and item.apiVersion.startswith("argoproj.io"):
        path = item?.spec?.source?.path
        chart = item?.spec?.source?.chart
        server = item?.destination?.server
        name = item?.spec?.destination?.name
        assert (path or chart) and not (path and chart), "`spec.source.path` OR `spec.source.chart` should be specified but never both."
        assert (server or name) and not (server and name), "`spec.destination.server` OR `spec.destination.name` should be specified but never both."
    item
}
# Validate All resource
items = [validate(i) for i in option("items") or []]

if option("__test__"):
    validate(yaml.decode("""\
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: badapp01
  namespace: default
spec:
  project: foo
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
    # chart: foo
  destination:
    server: https://kubernetes.default.svc
    namespace: guestbook
    """))
