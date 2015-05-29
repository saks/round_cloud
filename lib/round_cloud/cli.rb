require 'bundler/gem_helper'
require 'thor'

module RoundCloud
  class RoundCloud::CLI < Thor
    GEM_VERSION_PLACEHOLDER = '\b\S\+::VERSION'

    attr_reader :package_cloud

    desc 'release', 'release new version of a package and push to packagecloud.io'
    option :pre, type: :boolean, default: false
    def release
      if options[:pre]
        setup_prerelease_env!
      else
        if gemspec_version.prerelease?
          ui.error "Cannot release version #{gemspec_version} as stable!"
          exit 1
        end
      end
      do_release
    end

    private

    def setup_prerelease_env!
      @prerelease = true

      if gemspec_version.prerelease?
        add_build_number_to_gemspec_version
      else
        ui.error "Cannot release version `#{gemspec_version}' as prerelease!"
        exit 1
      end
    end

    def do_release
      with_uniq_gemspec_version { package_cloud.publish gem_helper.build_gem }
    end

    def prerelease?
      !!@prerelease
    end

    def with_uniq_gemspec_version
      if prerelease?
        change_version_in_gemspec
        yield
        revert_version_in_gemspec
      else
        yield
      end
    rescue PackageCloud::MissingConfigError => e
      ui.error 'Cannot proceed. Exiting.'
      exit 1
    end

    def change_version_in_gemspec
      `sed -i -e 's/#{GEM_VERSION_PLACEHOLDER}/"#{gemspec_version}"/' #{gem_helper.spec_path}`
    end

    def revert_version_in_gemspec
      `sed -i -e 's/"#{gemspec_version}"/#{GEM_VERSION_PLACEHOLDER}/' #{gem_helper.spec_path}`
    end

    # If there is no build number in gemspec version, add it.
    # Fail if there is no build number defined. We cannot push uniq build without build number.
    def add_build_number_to_gemspec_version
      build_number = ENV.fetch('CIRCLE_BUILD_NUM') do
        ui.error 'Cannot find build number!'
        exit 1
      end

      return if gemspec_version.version.end_with? ".#{build_number}"

      gem_helper.gemspec.version = Gem::Version.new "#{gemspec_version}.#{build_number}"
    end

    def ui
      @ui ||= Bundler::UI::Shell.new
    end

    def gem_helper
      @gem_helper ||= Bundler::GemHelper.new
      Bundler.ui = Bundler::UI::Silent.new
      @gem_helper
    end

    def gemspec_version
      gem_helper.gemspec.version
    end

    def package_cloud
      @package_cloud ||= PackageCloud.new ui, gem_helper
    end
  end
end
