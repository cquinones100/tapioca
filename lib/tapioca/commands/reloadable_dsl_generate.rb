# typed: strict
# frozen_string_literal: true

module Tapioca
  module Commands
    class ReloadableDslGenerate < DslGenerate
      sig { params(paths: T::Array[Pathname]).void }
      def rerun(paths:)
        @first_run ||= T.let(
          begin
            if @first_run.nil?
              true
            else
              @first_run
            end
          end,
          T.nilable(T::Boolean),
        )

        @requested_paths = paths

        execute
      ensure
        @first_run = false
        @pipeline = nil
      end

      private

      sig { override.void }
      def load_application
        if @first_run
          super
        else
          say("Rerunning Tapioca...")

          Loaders::ReloadableDsl.load_application(
            tapioca_path: @tapioca_path,
            eager_load: @requested_constants.empty? && @requested_paths.empty?,
            app_root: @app_root,
            halt_upon_load_error: @halt_upon_load_error,
          )
        end
      end

      sig { override.params(files: T::Set[Pathname]).void }
      def purge_stale_dsl_rbi_files(files)
        # no-op
        # we don't purge stale dsl rbi files when reloading
        # since we are always running tapioca dsl with paths
        # and certain paths cause a purge of all dsl rbi files
        # example: running tapioca dsl with config/routes.rb
      end
    end
  end
end
