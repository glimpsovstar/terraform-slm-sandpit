{
  "example1_foo": "{{ with secret "secrets/data/example1" }}{{ .Data.data.foo }}{{ end }}",
  "machine_id_jwt": "{{with secret "identity/oidc/token/${token_role}" }}{{ .Data.token }}{{ end }}"
}