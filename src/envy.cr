require "yaml"

require "./envy/version"
require "./envy/*"

module Envy
  extend self

  def from_file(*files, perm : Int32? = nil) : Nil
    load do
      set_perms files, perm

      files.each do |file|
        return from_file(file, force: false) if File.readable?(file)
      end

      raise Error.new("files (#{files.join(", ")}) not found or not readable")
    end
  end

  def from_file!(*files, perm : Int32? = nil) : Nil
    load do
      set_perms files, perm

      files.each do |file|
        return from_file(file, force: true) if File.readable?(file)
      end

      raise Error.new("files (#{files.join(", ")}) not found or not readable")
    end
  end

  private def from_file(file, *, force : Bool) : Nil
    File.open(file) do |file| # ameba:disable Lint/ShadowingOuterLocalVar
      load YAML.parse(file), force: force
    end
  end

  private def set_perms(files : Tuple, perm : Int32? = nil) : Nil
    perm = 0o600 if perm.nil?

    files.each do |file|
      File.chmod(file, perm) if File.exists?(file)
    end
  end

  private def load(yaml, prev_key = "", *, force)
    case raw = yaml.raw
    when Hash
      raw.each do |key, value|
        env_key = "#{prev_key}_#{key.to_s.upcase}".lchop('_')
        load(value, env_key, force: force)
      end
    when Array, Set
      raw.each_with_index do |value, index|
        env_key = "#{prev_key}_#{index}".lchop('_')
        load(value, env_key, force: force)
      end
    else
      unless prev_key.empty?
        ENV[prev_key] = raw.to_s if force || ENV[prev_key]?.nil?
      end
    end
  end

  private def load
    var = "ENVY_LOADED"

    unless ENV[var]? == "yes"
      yield
      ENV[var] = "yes"
    end
  end
end
