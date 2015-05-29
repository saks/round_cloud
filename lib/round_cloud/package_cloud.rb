module RoundCloud
  class PackageCloud
    TOKEN = 'PACKAGECLOUD_TOKEN'
    USER  = 'PACKAGECLOUD_REPO_USER'
    REPO  = 'PACKAGECLOUD_REPO_NAME'

    MissingConfigError = Class.new StandardError

    attr_reader :ui, :gem_helper

    def initialize(ui, gem_helper)
      @ui         = ui
      @gem_helper = gem_helper
    end

    def publish(package_path)
      ui.info "pushing #{package_path} package..."

      cmd     = release_cmd package_path
      out     = run_command cmd
      version = gem_helper.gemspec.version

      if '{}' == out
        ui.confirm "Successfully pushed new package version `#{version}'"
        ui.confirm "Add to Gemfile: \"gem '#{gem_helper.gemspec.name}', '#{version}'\""
      else
        ui.error "Failed to push version `#{version}', error: `#{out}'"
      end
    end

    private

    def run_command(cmd)
      `#{cmd}`
    end

    def token
      ENV.fetch(TOKEN) do
        ui.error "Failed to find env var with packagecloud token. Create env var `#{TOKEN}'"
        fail MissingConfigError
      end
    end

    def repo_name
      ENV.fetch(REPO) do
        ui.error "Failed to find env var with packagecloud repo name. Create env var `#{REPO}'"
        fail MissingConfigError
      end
    end

    def repo_user
      ENV.fetch(USER) do
        ui.error "Failed to find env var with packagecloud repo user. Create env var `#{USER}'"
        fail MissingConfigError
      end
    end

    def api_uri
      "https://#{token}:@packagecloud.io/api/v1/repos/#{repo_user}/#{repo_name}/packages.json"
    end

    def release_cmd(package_path)
      %Q(curl -X POST #{api_uri} -F 'package[package_file]=@#{package_path}' 2>/dev/null)
    end
  end
end
