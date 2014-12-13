require 'bundler'

require 'pathname'
require 'json'

module InvokesRspec
  def self.included(group)
    group.before(:all) { bundle_install }
  end

  private

  def gemfile_env
    {}
  end

  def gemfile_path
    Pathname(__FILE__).dirname.join('Gemfile')
  end

  def bundle_install
    gemfile_lock = gemfile_path.dirname.join('Gemfile.lock')
    gemfile_lock.unlink if gemfile_lock.exist?
    invoke_bundler(:install, '--local') || invoke_bundler(:install)
  end

  def rspec_result(specfile = nil)
    specfile ||= prepare_specfile

    output = invoke_bundler(:exec, :rspec, '--format', 'json', specfile) do |arglist|
      #system(*arglist)
      `#{arglist.shelljoin}`
    end
    raise "rspec gave no output, file not found?, syntax error in spec file? excption outside example?" if output.empty?

    # rspec-rails 2.99 pollutes STDOUT with a deprecation warning. Work around that.
    # This workaround assumes the warning does not contain a '{', while the JSON starts with it
    output = output[%r{\A[^\{]*(.*)}m, 1]

    _convert_raw_rspec_result(JSON.parse(output))
  end

  def prepare_specfile
    path = Pathname(__FILE__).dirname.join('../_generated_spec.rb')
    path.open('w') do |file|
      file << rspec_file_content
    end

    root_path = Pathname(__FILE__).parent.parent.parent

    path.relative_path_from(root_path)
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

  def _convert_raw_rspec_result(json)
    examples = json['examples'].map { |raw| example_class.new(raw) }
    RSpecResult.new(json, examples)
  end

  RSpecResult = Struct.new(:original_json, :examples)

  class Example
    attr_reader :raw

    def initialize(raw)
      @raw = raw
    end

    def full_description
      raw['full_description']
    end

    def line_number
      raw['line_number']
    end

    def status
      raw['status'].to_sym
    end

    def passed?
      status == :passed
    end

    def pending?
      status == :pending
    end

    def failed?
      status == :failed
    end

    def exception_message
      raw.fetch('exception').fetch('message')
    end

    def payload
      Marshal.load(exception_message)
    end

    def inspect
      hash = {
        line: line_number,
        status: status
      }
      hash[:exception_message] = exception_message if failed?

      segments = [
        'Example',
        *hash.map { |key, value| "#{key}: #{value.inspect}" }
      ]
      segments.join(' ')
    end
  end

  def example_class
    Example
  end
end

