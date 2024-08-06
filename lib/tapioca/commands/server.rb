# typed: strict
# frozen_string_literal: true

require "listen"

module Tapioca
  module Commands
    class Server
      extend T::Sig

      sig do
        params(
          requested_constants: T::Array[String],
          requested_paths: T::Array[Pathname],
          outpath: Pathname,
          only: T::Array[String],
          exclude: T::Array[String],
          file_header: T::Boolean,
          tapioca_path: String,
          skip_constant: T::Array[String],
          quiet: T::Boolean,
          verbose: T::Boolean,
          number_of_workers: T.nilable(Integer),
          auto_strictness: T::Boolean,
          gem_dir: String,
          rbi_formatter: RBIFormatter,
          app_root: String,
          halt_upon_load_error: T::Boolean,
          compiler_options: T::Hash[String, T.untyped],
        ).void
      end
      def initialize(
        requested_constants:,
        requested_paths:,
        outpath:,
        only:,
        exclude:,
        file_header:,
        tapioca_path:,
        skip_constant: [],
        quiet: false,
        verbose: false,
        number_of_workers: nil,
        auto_strictness: true,
        gem_dir: DEFAULT_GEM_DIR,
        rbi_formatter: DEFAULT_RBI_FORMATTER,
        app_root: ".",
        halt_upon_load_error: true,
        compiler_options: {}
      )
        @app_root = app_root

        @options = T.let(
          {
            requested_constants: requested_constants,
            requested_paths: requested_paths,
            outpath: outpath,
            only: only,
            exclude: exclude,
            file_header: file_header,
            tapioca_path: tapioca_path,
            skip_constant: skip_constant,
            quiet: quiet,
            verbose: verbose,
            number_of_workers: number_of_workers,
            auto_strictness: auto_strictness,
            gem_dir: gem_dir,
            rbi_formatter: rbi_formatter,
            app_root: app_root,
            halt_upon_load_error: halt_upon_load_error,
            compiler_options: compiler_options,
          },
          {
            requested_constants: T::Array[String],
            requested_paths: T::Array[Pathname],
            outpath: Pathname,
            only: T::Array[String],
            exclude: T::Array[String],
            file_header: T::Boolean,
            tapioca_path: String,
            skip_constant: T::Array[String],
            quiet: T::Boolean,
            verbose: T::Boolean,
            number_of_workers: T.nilable(Integer),
            auto_strictness: T::Boolean,
            gem_dir: String,
            rbi_formatter: RBIFormatter,
            app_root: String,
            halt_upon_load_error: T::Boolean,
            compiler_options: T::Hash[String, T.untyped],
          },
        )
      end

      sig { void }
      def run
        puts "Starting Tapioca server..."
        puts "Listening for changes in #{@app_root}..."

        listener = Listen.to(@app_root) do |modified, added, removed|
          if modified.find do |p|
            p = T.cast(p, Pathname)

            p.to_s.end_with?(".rb")
          end
            puts "Modified: #{modified.join(", ")}"

            generator = Tapioca::Commands::DslGenerate.new(**@options)

            generator.run
          end
        end

        listener.start

        sleep
      end
    end
  end
end
