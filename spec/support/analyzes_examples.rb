module AnalyzesExamples
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
  end

  def convert_examples(result)
    result['examples'].map do |raw|
      example_class.new(raw)
    end
  end

  def example_class
    Example
  end
end

