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

      sig { override.returns(Tapioca::Dsl::Pipeline) }
      def create_pipeline
        Tapioca::Dsl::ReloadablePipeline.new(
          requested_constants: constants_from_requested_paths.map(&:constantize),
          requested_paths: [],
          requested_compilers: constantize_compilers(@only),
          excluded_compilers: constantize_compilers(@exclude),
          error_handler: ->(error) {
            say_error(error, :bold, :red)
          },
          skipped_constants: constantize(@skip_constant, ignore_missing: true),
          number_of_workers: @number_of_workers,
          compiler_options: @compiler_options,
        )
      end

      sig { returns(T::Array[String]) }
      def constants_from_requested_paths
        Static::SymbolLoader.symbols_from_paths(@requested_paths).to_a
      end

      sig { override.params(compiler_names: T::Array[String]).returns(T::Array[T.class_of(Tapioca::Dsl::Compiler)]) }
      def constantize_compilers(compiler_names)
        compiler_map = compiler_names.to_h do |name|
          [name, resolve(name)]
        end

        unprocessable_compilers = compiler_map.select { |_, v| v.nil? }

        unless unprocessable_compilers.empty?
          message = unprocessable_compilers.map do |name, _|
            set_color("Warning: Cannot find compiler '#{name}'", :yellow)
          end.join("\n")

          say(message)
          say("")
        end

        T.cast(compiler_map.values, T::Array[T.class_of(Tapioca::Dsl::Compiler)])
      end
    end
  end
end
