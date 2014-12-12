module ContainExactlyShim
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
end

