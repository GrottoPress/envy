require "yaml"

require "./envy/version"
require "./envy/*"

module Envy
  extend self

  DEFAULT_FILE_PERM = 0o600

  def from_file(*files, perm = DEFAULT_FILE_PERM)
    load do
      files.each do |file|
        return from_file(file, perm, force: false) if File.readable?(file)
      end

      raise Error.new("files (#{files.join(", ")}) not found or not readable")
    end
  end

  def from_file!(*files, perm = DEFAULT_FILE_PERM)
    load do
      files.each do |file|
        return from_file(file, perm, force: true) if File.readable?(file)
      end

      raise Error.new("files (#{files.join(", ")}) not found or not readable")
    end
  end

  private def from_file(file, perm : Int32 = DEFAULT_FILE_PERM, *, force : Bool)
    File.chmod(file, perm)

    File.open(file, perm: perm) do |file|
      load Hash(YAML::Any, YAML::Any).from_yaml(file), force: force
    end
  end

  private def load(yaml : Hash, prev_key = "", *, force : Bool) : Nil
    yaml.each do |key, val|
      env_key = "#{prev_key}_#{key}".upcase.lchop('_')

      case raw = val.raw
      when Hash
        load raw, env_key, force: force
      when Array
        raw.each_with_index do |x, i|
          env_key_i = "#{env_key}_#{i}".lchop('_')
          ENV[env_key_i] = x.to_s if force || ENV[env_key_i]?.nil?
        end
      else
        ENV[env_key] = val.to_s if force || ENV[env_key]?.nil?
      end
    end
  end

  private def load(& : Proc(Nil)) : Nil
    unless ENV[var = "ENVY_LOADED"]?
      yield
      ENV[var] = "yes" unless ENV[var]?
    end
  rescue err : Exception
    raise Error.new(err.message)
  end
end
