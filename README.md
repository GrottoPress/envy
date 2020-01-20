# Envy

**Envy** loads and sets environment variables from YAML. It supports all YAML data types, including arrays and hashes.

**Envy** uses the YAML key mapping of a value as the environment variable name.

For example, the following YAML configuration...

```yaml
---
app:
  database:
    host: localhost
    port: 4321
  server:
    hosts:
      - localhost
      - grottopress.localhost
    port: 8080
```

...sets environment variables as follows:

```bash
ENV["APP_DATABASE_HOST"] = "localhost"
ENV["APP_DATABASE_PORT"] = "4321"
ENV["APP_SERVER_HOSTS_0"] = "localhost"
ENV["APP_SERVER_HOSTS_1"] = "grottopress.localhost"
ENV["APP_SERVER_PORT"] = "8080"
```

**Envy** loads environment variables only once per application life-cycle. This avoids the overhead of reading and parsing YAML files on every single request.

**Envy** sets file permission (`0600` by default) for the loaded config file.

**Envy** supports loading a file from a supplied list of files in decreasing order of priority; the first readable file is loaded.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     envy:
       github: grottopress/envy
   ```

2. Run `shards install`

## Usage

- Load the first readable file from a supplied list of files. Optionally set file permissions. This does *not* overwrite existing environment variables:

    ```crystal
    require "envy"

    Envy.from_file ".env.yml", ".env.dev.yml", perm: 0o400
    ```

 - Load the first readable file from a supplied list of files. Optionally set file permissions. This *overwrites* existing environment variables:

    ```crystal
    require "envy"

    Envy.from_file! ".env.yml", ".env.dev.yml", perm: 0o400
    ```

## Contributing

1. Fork it (<https://github.com/grottopress/envy/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
