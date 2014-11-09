require 'shellwords'
require 'json'
require 'pathname'

require 'bundler'

#require 'pry'
#require 'pry-byebug'

describe "foo" do
  context "foo" do
    before(:all) do
      bundle_install
    end

    def gemfile_env
      { 'RAILS_VERSION' => '4.2.0.beta2'}
    end

    it "passes RouteWrapper tests" do
      expect(rspec_result('spec/lib/route_wrapper_spec.rb')).to contain_only_passed_examples
    end
  end

  private

  def contain_only_passed_examples
    satisfy do |rspec_result|
      rspec_result['examples'].all? { |example| example['status'] == 'passed' }
    end
  end

  def gemfile_path
    Pathname(__FILE__).parent.join('support/Gemfile')
  end

  def bundle_install
    gemfile_lock = gemfile_path.dirname.join('Gemfile.lock')
    gemfile_lock.unlink if gemfile_lock.exist?
    invoke_bundler(:install, '--local') || invoke_bundler(:install)
  end

  def rspec_result(specfile)
    output = invoke_bundler(:exec, :rspec, '--format', 'json', specfile) do |arglist|
      #system(*arglist)
      `#{arglist.shelljoin}`
    end
    raise "rspec gave no output, file not found?, syntax error in spec file? excption outside example?" if output.empty?
    JSON.parse(output)
  end

  def invoke_bundler(*args)
    old_env = ENV.to_hash.clone
    arglist = if [:install, :check].include? args.first.to_s
      # apparently we NEED to pass the --gemfile option, the env var is not honored
      [:bundle, args.first, '--gemfile', gemfile_path, *args.drop(1)].map(&:to_s)
    else
      [:bundle, args.first, *args.drop(1)].map(&:to_s)
    end
    Bundler.with_clean_env do
      # BUNDLE_GEMFILE is only used when command is exec
      env = gemfile_env.merge('BUNDLE_GEMFILE' => gemfile_path.to_s)
      ENV.replace ENV.to_hash.merge(env)

      if block_given?
        yield arglist
      else
        system(*arglist)
      end
    end
  ensure
    # apparently, Bundler.with_clean_env already resets ENV for us, but I don't like to assume that
    ENV.replace old_env
  end
end

