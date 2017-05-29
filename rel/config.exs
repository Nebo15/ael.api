use Mix.Releases.Config,
  default_release: :default,
  default_environment: :default

cookie = :sha256
|> :crypto.hash(System.get_env("ERLANG_COOKIE") || "03/yHifHIElaQhFl/IPyD18ZWzhsbNKgrZFdNblyJA6/g/T2RD936cypCDDXsi7w")
|> Base.encode64

environment :default do
  set pre_start_hook: "bin/hooks/pre-start.sh"
  set dev_mode: false
  set include_erts: false
  set include_src: false
  set cookie: cookie,
  set overlays: [
    {:template, "rel/templates/vm.args.eex", "releases/<%= release_version %>/vm.args"}
  ]
end

release :ael_api do
  set version: current_version(:ael_api)
  set applications: [
    ael_api: :permanent
  ]
end
