require 'haml'

module Haml
    module Helpers
        def get_version
            @@livesearchversion ||= File.read('VERSION').strip
            @@livesearchversion
        end
    end
end
