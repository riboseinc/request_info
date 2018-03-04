# (c) Copyright 2017 Ribose Inc.
#

RSpec::Matchers.define_negated_matcher :exclude, :include
RSpec::Matchers.define_negated_matcher :preserve, :change
