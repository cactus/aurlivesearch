# Copyright (c) 2011 github.com/cactus
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require "rubygems"
require "bundler/setup"
require 'rake'
require 'yaml'

ROOT_D = File.dirname(__FILE__)

task :default => :compile

###
### Compile tasks for coffee
desc "Compile coffee scripts"
task :compile => [
    "compile:haml", 
    "compile:coffee",
    "compile:html",
    "compile:uglify"]

namespace "compile" do
    desc "create dist dir if it doesn't exist"
    task :dist_dir do
        if not File.directory? 'dist/static'
            mkdir_p "dist/static"
        end
        if not File.directory? 'dist/compiled'
            mkdir_p "dist/compiled"
        end
    end

    desc "clean dist dir"
    task :clean do
        if File.directory? 'dist'
            rm_rf 'dist'
        end
    end

    desc "compmile coffee scripts to js"
    task :coffee do
        ## coffee compiler outputs compiled js in same location as src
        sh "coffee -l -o dist/compiled -c src/compiled"
    end
    task :coffee => 'compile:dist_dir'

    desc "watch-compile coffee scripts to js"
    task :coffee_watch do
        # same as coffee:compile, but also add watch
        exec "coffee -l -w -o dist/compiled -c src/compiled"
    end
    task :coffee_watch => 'compile:dist_dir'
   
    desc "copy static files to dist"
    task :html do
        cp_r Dir.glob("src/static/*"), 'dist/static/'
    end
    task :html => 'compile:dist_dir'

    desc "compile haml html template"
    task :haml do
        Dir.glob('src/*.haml').each do |lf|
            outfile = File.join('dist', 
                File.basename(lf).sub('.haml', '.html'))
            sh "haml -q -f html5 -e #{lf} #{outfile}"
        end
    end
    task :haml => 'compile:dist_dir'

    desc "uglify.js"
    task :uglify do
        Dir.glob('dist/compiled/*.js').each do |lf|
            sh "uglifyjs --overwrite #{lf}"
        end
    end
    task :uglify => 'compile:dist_dir'
end

desc "deploy to production env"
task :deploy do
    if File.exists? '.config.yml'
        #try to read from file
        conf = File.read('.config.yml')
        prod_host_loc = YAML.load(conf)['prod_host_loc']
    else
        #try to read from env
        prod_host_loc = ENV['PROD_HOST_LOC']
    end
    abort "'prod_host_loc' is not set. Not deploying." unless prod_host_loc
    sh "rsync -avzc --delete-after dist/ #{prod_host_loc}"
end
task :deploy => ["compile:clean", "compile"]

desc "server locally for testing"
task :serve do
    require 'webrick'
    include WEBrick
    s = HTTPServer.new(
        :Port => 8000,
        :BindAddress => '127.0.0.1',
        :DocumentRoot => 'dist/'
    )
    trap("INT") { s.shutdown }
    puts "Starting server at http://127.0.0.1:8000/"
    s.start
end
task :serve => ["compile:clean", "compile"]
