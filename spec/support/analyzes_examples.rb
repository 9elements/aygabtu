module AnalyzesExamples
  Example = Struct.new(:full_description, :line_number, :status) do
    def passed?
      status == :passed
    end

    def pending?
      status == :pending
    end

    def failed?
      status == :failed
    end

    def group_passing?
      enclosing_group == :passing
    end

    def group_pending?
      enclosing_group == :pending
    end

    def group_failing?
      enclosing_group == :failing
    end

    def group_partly_failing?
      enclosing_group == :partial
    end

    def group_no_example?
      enclosing_group == :no_example
    end

    private

    def enclosing_group
      case full_description
      when /\bEXAMPLE PASSING\b/
        :passing
      when /\bEXAMPLE PENDING\b/
        :pending
      when /\bEXAMPLE FAILING\b/
        :failing
      when /\bEXAMPLES PARTLY FAILING\b/
        :partial
      when /\bNO EXAMPLE\b/
        :no_example
      else
        raise "unrecognized enclosing example group for example #{inspect}"
      end
    end
  end

  def convert_examples(result)
    result['examples'].map do |raw|
      Example.new(
        raw['full_description'],
        raw['line_number'],
        raw['status'].to_sym
      )
    end
  end
end

