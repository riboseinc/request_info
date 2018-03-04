# (c) Copyright 2017 Ribose Inc.
#

RSpec::Matchers.define :point_to_existing_file do
  match do |actual|
    actual.present? && actual.is_a?(String) && File.exists?(actual)
  end
end
