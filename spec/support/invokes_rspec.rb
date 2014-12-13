require 'pathname'
require 'json'

module InvokesRspec
  private

  def rspec_result(specfile = nil)
    specfile ||= prepare_specfile

    arglist = [:rspec, '--format', 'json', specfile]
    output = `#{arglist.shelljoin}`
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

  def _convert_raw_rspec_result(json)
    examples = json['examples'].map { |raw| Example.new(raw) }
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
end

