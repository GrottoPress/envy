require "spec"

require "../src/envy"

ENV_FILE     = "./spec/_support/.env.yml"
ENV_DEV_FILE = "./spec/_support/.env.dev.yml"

private ENV_FILE_PERM     = File.info(ENV_FILE).permissions
private ENV_DEV_FILE_PERM = File.info(ENV_DEV_FILE).permissions

Spec.before_each do
  ENV.clear

  File.chmod ENV_FILE, ENV_FILE_PERM
  File.chmod ENV_DEV_FILE, ENV_DEV_FILE_PERM
end

Spec.after_suite do
  File.chmod ENV_FILE, ENV_FILE_PERM
  File.chmod ENV_DEV_FILE, ENV_DEV_FILE_PERM
end
