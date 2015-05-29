RSpec.describe RoundCloud::PackageCloud do
  let(:out) { '{}' }
  let(:ui) { double :ui, error: '', info: '', confirm: '' }
  let(:gemspec) { double :gemspec, version: Gem::Version.new('1.1.1'), name: 'foo' }
  let(:gem_helper) { double :gem_helper, gemspec: gemspec }
  before do
    allow_any_instance_of(described_class).to receive(:run_command).and_return out
  end

  let(:object) { described_class.new ui, gem_helper }

  context 'publish' do
    let(:package_path) { '/foo/bar' }
    let(:token) { 'foo-token' }
    let(:repo_name) { 'foo-repo-name' }
    let(:repo_user) { 'foo-repo-user' }

    before do
      allow(object).to receive_messages token: token, repo_name: repo_name, repo_user: repo_user
      object.publish package_path
    end

    subject { object }

    it { is_expected.to have_received(:run_command).with /#{token}/     }
    it { is_expected.to have_received(:run_command).with /#{repo_user}/ }
    it { is_expected.to have_received(:run_command).with /#{repo_name}/ }

    context 'success' do
      let(:out) { '{}' }

      context 'ui' do
        let(:confirm_text) { "Successfully pushed new package version `#{gemspec.version}'" }

        subject { ui }

        it { is_expected.to have_received(:info).with "pushing #{package_path} package..." }
        it { is_expected.to have_received(:confirm).with confirm_text }
      end
    end

    context 'fail' do
      let(:out) { '{number: "some kind of error"}' }

      context 'ui' do
        let(:error_text) { "Failed to push version `#{gemspec.version}', error: `#{out}'" }

        subject { ui }

        it { is_expected.to have_received(:info).with "pushing #{package_path} package..." }
        it { is_expected.to have_received(:error).with error_text }
        it { is_expected.to_not have_received :confirm }
      end
    end
  end

  context 'configuration check' do
    subject(:get_config) { -> { object.send method_name } }

    shared_examples 'ui shows an error' do
      before { begin; get_config.call; rescue; end }
      subject { ui }
      it { is_expected.to have_received(:error).with error_text }
    end

    context 'token' do
      let(:method_name) { 'token' }
      let(:error_text) { /packagecloud token/ }

      it { is_expected.to raise_error described_class::MissingConfigError }
      it_should_behave_like 'ui shows an error'
    end

    context 'repo user' do
      let(:method_name) { 'repo_user' }
      let(:error_text) { /packagecloud repo user/ }

      it { is_expected.to raise_error described_class::MissingConfigError }
      it_should_behave_like 'ui shows an error'
    end

    context 'repo name' do
      let(:method_name) { 'repo_name' }
      let(:error_text) { /packagecloud repo name/ }

      it { is_expected.to raise_error described_class::MissingConfigError }
      it_should_behave_like 'ui shows an error'
    end
  end
end
