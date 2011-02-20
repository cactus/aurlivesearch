require 'haml'

module Haml::Filters::Coffee
    include Haml::Filters::Base
    lazy_require 'coffee_script'

    def render_with_options(text, options)
        if options[:format] == :html5
            type = ''
        else
            type = " type=#{options[:attr_wrapper]}text/javascript#{options[:attr_wrapper]}"
        end
        js = CoffeeScript.compile(text, :bare => true)

        <<-END
<script#{type}>
  //<![CDATA[
    // compiled by coffee-script
    #{js.rstrip.gsub("\n", "\n    ")}
  //]]>
</script>
        END
    end
end
