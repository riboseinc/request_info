require "singleton"

module RequestInfo
  module Detectors
    # Base class for a Detector.
    #
    # A Detector is given the app's env
    # A Detector must implement the 'detect' method.
    #
    class Base
      include ::Singleton

      # `detect' is run prior to Rails processing on a request.
      # Typically this method is used to discover
      # something about the request, and return its discovery results.
      #
      # This method is also where you should set/modify global states about the
      # discovery if needed.
      #
      # To clear/reset global states, do it in the `after_app' method.
      #
      # This method must return a Hash in this format:
      # {
      #   :result_key => results1,
      #   :result_key2 => results2,
      #   ...
      # }
      #
      # The Hash values will be accessible at
      #   RequestInfo.results.{Hash key} => Hash value
      #
      # e.g.
      #   RequestInfo.results.result_key => results1,
      #   RequestInfo.results.result_key2 => results2
      #
      def detect(_env)
        raise NotImplementedError
      end

      # `after_app' is run after Rails processing on a request
      def after_app(status, headers, body)
      end
    end
  end
end
