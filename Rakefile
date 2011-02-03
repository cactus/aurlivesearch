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

ROOT_D = File.dirname(__FILE__)

###
### Compile tasks for coffee and less
desc "Compile coffee scripts and less css files"
task :compile => ["compile:slim", "compile:coffee", "compile:less", "compile:html", "compile:uglify"]

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
        sh "coffee -o dist/compiled -c src/compiled"
    end
    task :coffee => 'compile:dist_dir'

    desc "watch-compile coffee scripts to js"
    task :coffee_watch do
        # same as coffee:compile, but also add watch
        exec "coffee -w -o dist/compiled -c src/compiled"
    end
    task :coffee_watch => 'compile:dist_dir'
   
    desc "copy static files to dist"
    task :html do
        Dir.glob("src/static/*").each {|f| cp f, 'dist/static/' }
    end
    task :html => 'compile:dist_dir'

    desc "compile less scripts to css"
    task :less do
        Dir.glob('src/compiled/*.less').each do |lf|
            outfile = File.join('dist', 'compiled', File.basename(lf).sub('.less', '.css'))
            sh "lessc #{lf} #{outfile}"
        end
    end
    task :less => 'compile:dist_dir'

    desc "compile slim html template"
    task :slim do
        Dir.glob('src/*.slim').each do |lf|
            outfile = File.join('dist', File.basename(lf).sub('.slim', '.html'))
            sh "slimrb -p #{lf} > #{outfile}"
        end
    end
    task :slim => 'compile:dist_dir'

    desc "uglify.js"
    task :uglify do
        Dir.glob('dist/compiled/*.js').each do |lf|
            sh "uglifyjs --overwrite #{lf}"
        end
    end
    task :uglify => 'compile:dist_dir'
end

namespace "deploy" do
    # failsafe
    desc "deploy to production env"
    task :prod do
        abort "'PROD_HOST' is not set. Not deploying." unless ENV['PROD_HOST'] 
        sh "rsync -avz --delete-after dist/ #{ENV['PROD_HOST']}:/srv/www/aurlivesearch/"
    end
    task :prod => "compile"
end
