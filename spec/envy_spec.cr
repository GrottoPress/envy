require "./spec_helper"

describe Envy do
  describe ".from_file" do
    it "sets file permissions" do
      Envy.from_file ENV_FILE, ENV_DEV_FILE, "nop.yml"

      File.info(ENV_FILE).permissions.should(
        eq File::Permissions.new(0o600)
      )

      File.info(ENV_DEV_FILE).permissions.should(
        eq File::Permissions.new(0o600)
      )
    end

    context "when env vars do not exist" do
      it "loads env vars from yaml file" do
        Envy.from_file ENV_FILE

        ENV["APP_DATABASE_HOST"]?.should eq("grottopress.com")
        ENV["APP_DATABASE_PORT"]?.should eq("5432")
        ENV["APP_SERVER_HOSTS_0"]?.should eq("grottopress.com")
        ENV["APP_SERVER_HOSTS_1"]?.should eq("itechplus.org")
        ENV["APP_SERVER_PORT"]?.should eq("80")
      end
    end

    context "when env vars exist" do
      it "does not overwrite existing env vars" do
        ENV["APP_DATABASE_HOST"] = "abc.com"
        ENV["APP_DATABASE_PORT"] = "1234"
        ENV["APP_SERVER_HOSTS_0"] = "abc.net"
        ENV["APP_SERVER_HOSTS_1"] = "abc.org"

        Envy.from_file ENV_FILE

        ENV["APP_DATABASE_HOST"]?.should eq("abc.com")
        ENV["APP_DATABASE_PORT"]?.should eq("1234")
        ENV["APP_SERVER_HOSTS_0"]?.should eq("abc.net")
        ENV["APP_SERVER_HOSTS_1"]?.should eq("abc.org")
        ENV["APP_SERVER_PORT"]?.should eq("80")
      end
    end

    context "given multiple files" do
      it "loads the first readable file" do
        Envy.from_file "nop.yml", ENV_DEV_FILE, ENV_FILE

        ENV["APP_DATABASE_HOST"]?.should eq("localhost")
        ENV["APP_DATABASE_PORT"]?.should eq("4321")
        ENV["APP_SERVER_HOSTS_0"]?.should eq("localhost")
        ENV["APP_SERVER_HOSTS_1"]?.should eq("grottopress.localhost")
        ENV["APP_SERVER_PORT"]?.should eq("8080")
      end
    end

    context "given non-existent files" do
      it "raises an exception" do
        expect_raises Envy::Error do
          Envy.from_file "nop.yml", "nop2.yml"
        end
      end
    end
  end

  describe ".from_file!" do
    it "sets file permissions" do
      Envy.from_file! ENV_DEV_FILE, ENV_FILE, "nop.yml", perm: 0o400

      File.info(ENV_DEV_FILE).permissions.should(
        eq File::Permissions.new(0o400)
      )

      File.info(ENV_FILE).permissions.should(
        eq File::Permissions.new(0o400)
      )
    end

    context "when env vars do not exist" do
      it "loads env vars from yaml file" do
        Envy.from_file! ENV_FILE

        ENV["APP_DATABASE_HOST"]?.should eq("grottopress.com")
        ENV["APP_DATABASE_PORT"]?.should eq("5432")
        ENV["APP_SERVER_HOSTS_0"]?.should eq("grottopress.com")
        ENV["APP_SERVER_HOSTS_1"]?.should eq("itechplus.org")
        ENV["APP_SERVER_PORT"]?.should eq("80")
      end
    end

    context "when env vars exist" do
      it "overwrites existing env vars" do
        ENV["APP_DATABASE_HOST"] = "abc.com"
        ENV["APP_DATABASE_PORT"] = "1234"
        ENV["APP_SERVER_HOSTS_0"] = "abc.net"
        ENV["APP_SERVER_HOSTS_1"] = "abc.org"

        Envy.from_file! ENV_FILE

        ENV["APP_DATABASE_HOST"]?.should eq("grottopress.com")
        ENV["APP_DATABASE_PORT"]?.should eq("5432")
        ENV["APP_SERVER_HOSTS_0"]?.should eq("grottopress.com")
        ENV["APP_SERVER_HOSTS_1"]?.should eq("itechplus.org")
        ENV["APP_SERVER_PORT"]?.should eq("80")
      end
    end

    context "given multiple files" do
      it "loads the first readable file" do
        Envy.from_file! "nop.yml", ENV_DEV_FILE, ENV_FILE

        ENV["APP_DATABASE_HOST"]?.should eq("localhost")
        ENV["APP_DATABASE_PORT"]?.should eq("4321")
        ENV["APP_SERVER_HOSTS_0"]?.should eq("localhost")
        ENV["APP_SERVER_HOSTS_1"]?.should eq("grottopress.localhost")
        ENV["APP_SERVER_PORT"]?.should eq("8080")
      end
    end

    context "given non-existent files" do
      it "raises an exception" do
        expect_raises Envy::Error do
          Envy.from_file! "nop.yml", "nop2.yml"
        end
      end
    end
  end

  describe ".load" do
    context "when env file not loaded" do
      it "loads env file" do
        Envy.from_file ENV_FILE

        ENV["APP_DATABASE_HOST"]?.should eq("grottopress.com")
        ENV["APP_DATABASE_PORT"]?.should eq("5432")
        ENV["APP_SERVER_HOSTS_0"]?.should eq("grottopress.com")
        ENV["APP_SERVER_HOSTS_1"]?.should eq("itechplus.org")
        ENV["APP_SERVER_PORT"]?.should eq("80")
      end
    end

    context "when env file already loaded" do
      it "does not load env file again" do
        ENV["ENVY_LOADED"] = "yes"

        Envy.from_file ENV_FILE

        ENV["APP_DATABASE_HOST"]?.should eq(nil)
        ENV["APP_DATABASE_PORT"]?.should eq(nil)
        ENV["APP_SERVER_HOSTS_0"]?.should eq(nil)
        ENV["APP_SERVER_HOSTS_1"]?.should eq(nil)
        ENV["APP_SERVER_PORT"]?.should eq(nil)
      end
    end
  end
end
