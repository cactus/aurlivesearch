# Copyright (c) 2010 github.com/cactus
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
require 'digest/md5'

ROOT_D = File.dirname(__FILE__)

###
### Compile tasks for coffee and less
desc "Compile coffee scripts and less css files"
task :compile => ["compile:coffee", "compile:less", "compile:html", "compile:uglify"]

namespace "compile" do
    desc "clean dist dir"
    task :clean do
        rm Dir.glob('dist/*')
    end

    desc "compmile coffee scripts to js"
    task :coffee do
        ## coffee compiler outputs compiled js in same location as src
        sh "coffee -o dist/ -c src/"
    end

    desc "watch-compile coffee scripts to js"
    task :coffee_watch do
        # same as coffee:compile, but also add watch
        exec "coffee -w -o dist/ -c src/"
    end
   
    desc "copy static files to dist"
    task :html do
        cp Dir.glob("src/*.html"), 'dist'
        cp Dir.glob("src/*.js"), 'dist'
        cp Dir.glob("src/*.css"), 'dist'
    end

    desc "compile less scripts to css"
    task :less do
        Dir.glob('src/*.less').each do |lf|
            outfile = File.join('dist', File.basename(lf).sub('.less', '.css'))
            sh "lessc #{lf} #{outfile}"
        end
    end

    desc "uglify.js"
    task :uglify do
        Dir.glob('dist/*.js').each do |lf|
            sh "uglifyjs --overwrite #{lf}"
        end
    end
end

namespace "deploy" do
    # failsafe
    ENV['PROD_HOST'] ||= '0.0.0.0'
    desc "deploy to production env"
    task :prod do
        sh "rsync -avz --delete-after dist/ #{ENV['PROD_HOST']}:/srv/www/oogah/"
    end
    task :prod => "compile"
end
