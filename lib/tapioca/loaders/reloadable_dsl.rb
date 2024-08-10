# typed: strict
# frozen_string_literal: true

module Tapioca
  module Loaders
    class ReloadableDsl < Dsl
      extend T::Sig

      sig { override.void }
      def load_application
        load_dsl_extensions
        load_path = "config/application"

        require File.expand_path(load_path, @app_root)

        ::Rails.application.reloader.reload!

        load_dsl_compilers
      end
    end
  end
end
