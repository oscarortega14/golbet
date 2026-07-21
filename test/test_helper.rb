ENV["RAILS_ENV"] ||= "test"

# En macOS, libpq inicializa GSSAPI/Kerberos (frameworks que no son fork-safe),
# lo que cuelga la paralelización de tests (parallelize hace fork). Deshabilitar
# el cifrado GSS en la conexión evita que se cargue ese framework antes del fork.
ENV["PGGSSENCMODE"] ||= "disable"

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
