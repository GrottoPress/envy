require "yaml"

require "./envy/version"
require "./envy/*"

module Envy
  extend self

  DEFAULT_FILE_PERM = 0o600

  def from_file(*files, perm = DEFAULT_FILE_PERM)
    files.each do |file|
      return from_file(file, perm) if File.readable?(file)
    end

    raise Error.new("files (#{files.join(", ")}) not found or not readable")
  end

  def from_file!(*files, perm = DEFAULT_FILE_PERM)
    files.each do |file|
      return from_file!(file, perm) if File.readable?(file)
    end

    raise Error.new("files (#{files.join(", ")}) not found or not readable")
  end

  def from_file(file, perm : Int32 = DEFAULT_FILE_PERM)
    load { from_file file, perm, force: false }
  end

  def from_file!(file, perm : Int32 = DEFAULT_FILE_PERM)
    load { from_file file, perm, force: true }
  end

  private def from_file(file, perm : Int32 = DEFAULT_FILE_PERM, *, force : Bool)
    File.chmod(file, perm)
    File.open(file, perm: perm) { |f| from_yaml(f, force: force) }
  end

  private def from_yaml(yaml, *, force : Bool)
    load Hash(YAML::Any, YAML::Any).from_yaml(yaml), force: force
  end

  private def load(yaml : Hash, prev_key = "", *, force : Bool) : Nil
    prev_key = prev_key.upcase

    yaml.each do |key, val|
      key = key.to_s.upcase

      case raw = val.raw
      when Hash
        load raw, "#{prev_key}_#{key}".lchop('_'), force: force
      when Array
        raw.each_with_index do |x, i|
          env_key = "#{prev_key}_#{key}_#{i}".lchop('_')
          ENV[env_key] = x.to_s if force || ENV[env_key]?.nil?
        end
      else
        env_key = "#{prev_key}_#{key}".lchop('_')
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