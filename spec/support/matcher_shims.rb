module MatcherShims
  def contain_exactly(*objects_or_matchers)
    return super if defined?(super)

    satisfy do |actual|
      next false unless actual.length == objects_or_matchers.length

      objects_or_matchers.permutation.any? do |permutation|
        permutation.zip(actual).all? do |object_or_matcher, actual_item|
          if object_or_matcher.respond_to?(:matches?)
            object_or_matcher.matches?(actual_item)
          else
            object_or_matcher == actual_item
          end
        end
      end
    end
  end

  def all(matcher)
    return super if defined?(super)

    satisfy do |collection|
      collection.all? { |item| matcher.matches?(item) }
    end
  end

  module And
    def and(another_matcher)
      return super if defined?(super)

      RSpec::Matchers::BuiltIn::Satisfy.new do |actual|
        matches?(actual) && another_matcher.matches?(actual)
      end
    end
  end
end

RSpec::Matchers::BuiltIn::BaseMatcher.send :include, MatcherShims::And
