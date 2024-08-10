# typed: strict
# frozen_string_literal: true

module Tapioca
  module Dsl
    class ReloadablePipeline < Pipeline
      sig { params(constants: T::Set[Module]).returns(T::Set[Module]) }
      def filter_anonymous_and_reloaded_constants(constants)
        constants
      end

      sig do
        params(
          requested_constants: T::Array[Module],
          requested_paths: T::Array[Pathname],
          skipped_constants: T::Array[Module],
        ).returns(T::Set[Module])
      end
      def gather_constants(requested_constants, requested_paths, skipped_constants)
        Set.new(requested_constants)
      end
    end
  end
end
