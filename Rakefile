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
AURSEARCHVER = File.read('VERSION').strip

task :default => :compile

desc "clean dist dir"
task :clean do
    puts "cleaning"
    if File.directory? 'dist'
        rm_rf 'dist'
    end
    if File.exists? 'src/include/search.js'
        rm_rf 'src/include/search.js'
    end
    puts ""
end
    
# no desc, hide from rake -T
task :mk_dist_dir do
    if not File.directory? 'dist/static'
        mkdir_p "dist/static"
    end
end

###
### Compile tasks for coffee
desc "Compile action"
task :compile => [ "compile:haml", "compile:static"]

namespace "compile" do
    desc "copy static files to dist"
    task :static => [:mk_dist_dir] do
        puts "copying static files"
        cp_r Dir.glob("src/static/*"), 'dist/static/'
        puts ""
    end

    desc "compile haml to html"
    task :haml => [:mk_dist_dir] do
        puts "compiling haml template"
        require 'haml'
        require_relative 'lib/filters'
        options = {
            :format => :html5,
            :escape_html => true,
            :attr_wrapper => %q{"}
        }
        infile = File.join('src', 'index.haml') 
        outfile = File.join('dist', 'index.html')
        puts "writing #{infile} -> #{outfile}"
        File.open(outfile, 'w') { |f|
            haml_engine = Haml::Engine.new(File.read(infile), options)
            f.write(haml_engine.render)
        }
        puts ""
    end
    task :haml => "compile:uglify"

    desc "compile coffee-script to js"
    task :coffee => [:mk_dist_dir] do
        puts "compiling coffee scripts to js"
        ## coffee compiler outputs compiled js in same location as src
        sh "coffee -b -l -c src/include"
        puts ""
    end
    
    desc "compress js with uglify.js"
    task :uglify => [:mk_dist_dir] do
        puts "compressing javascript files"
        FileList['src/include/search.js'].each do |lf|
            sh "uglifyjs --overwrite #{lf}"
        end
        puts ""
    end
    task :uglify => "compile:coffee"
end

desc "deploy to production env"
task :deploy, [:dry_run] => [:clean, :compile] do |t, args|
    args.with_defaults(:dry_run => false)
    rsync_extra_args = args.dry_run ? '-n' : ''
    if File.exists? '.config.yml'
        #try to read from file
        conf = File.read('.config.yml')
        prod_host_loc = YAML.load(conf)['prod_host_loc']
    else
        #try to read from env
        prod_host_loc = ENV['PROD_HOST_LOC']
    end
    abort "'prod_host_loc' is not set. Not deploying." unless prod_host_loc
    sh "rsync #{rsync_extra_args} -avzc --delete-after dist/ #{prod_host_loc}"
end

desc "server locally for testing"
task :serve => [:clean, :compile] do
    require 'webrick'
    include WEBrick
    s = HTTPServer.new(
        :Port => 8000,
        :BindAddress => '127.0.0.1',
        :AccessLog =>  [ [ $stderr, AccessLog::COMMON_LOG_FORMAT ] ],
        :DocumentRoot => 'dist/'
    )
    # return 404 for favicon
    s.mount_proc('/favicon.ico') {|req, resp|
        resp.status = 404
        resp['Content-Type'] = 'image/png'
        resp['Cache-Control'] = 'public, max-age=100000000000'
    }
    trap("INT") { s.shutdown }
    puts "Starting server at http://127.0.0.1:8000/"
    s.start
end
