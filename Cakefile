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

fs = require 'fs'
{exec} = require 'child_process'
jade = require 'jade'
coffee = require 'coffee-script'
uglifyjs = require 'uglify-js'

# helper functions
uglifycoffee = (str) ->
    js = coffee.compile(str, {bare: true})

    ## uglify
    ast = uglifyjs.parser.parse(js)
    ast = uglifyjs.uglify.ast_mangle(ast)
    ast = uglifyjs.uglify.ast_squeeze(ast)
    js = uglifyjs.uglify.gen_code(ast)
    js.trim()

# ANSI Terminal Colors.
bold  = "\033[0;1m"
red   = "\033[0;31m"
green = "\033[0;32m"
reset = "\033[0m"

# Log a message with a color.
log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')


## options
option '-n', '--dry-run', 'dry run for deploy'

## cake tasks
task 'clean', 'clean dist dir', ->
    exec 'rm -rf ./dist', (error) ->
        console.log('could remove ./dist dir') if error?
        
task 'compile', 'compile the whole thing', ->
    lc =
      AURSEARCHVER: fs.readFileSync('VERSION', 'utf-8')
      icanhazjs: fs.readFileSync('src/ICanHaz.min.js', 'utf-8')
      search_coffee: uglifycoffee(fs.readFileSync('src/search.coffee', 'utf-8'))
      inline_css: fs.readFileSync('src/screen.css', 'utf-8')

    jade.renderFile('src/index.jade', { locals: lc }, (err, html) ->
        if err
            console.log 'failed to compile jade template'
            console.log(err.message)
            process.exit(1)
        fs.writeFileSync("dist/index.html", html, 'utf-8')
    )

task 'copy_files', 'copy static files into staging dir', ->
    exec 'cp -r static/ dist/static/', (error) ->
        console.log('could not copy files') if error?

task 'mkdir', 'create dist directory if it does not exist', ->
    try
        fs.mkdirSync('./dist', 0755)
    catch e
        console.log('"./dist" dir already exists')
        throw e unless e.code == 'EEXIST'

task 'deploy', 'deploy to prod -- read config.json for prod config', (options) ->
    jdata = JSON.parse(fs.readFileSync('./config.json', 'utf-8'))
    if not jdata.prod_host_loc
        console.log('invalid ./config.json')
        process.exit(1)
    rsync_extra_args = if options['dry-run'] then '-n' else ''
    exec_str = "rsync #{rsync_extra_args} -avzc --delete-after dist/ #{jdata.prod_host_loc}"
    console.log(exec_str)
    exec exec_str, (error, stdout, stderr) ->
        log stderr, red
        log stdout, green

task 'main', 'Main task. Does everything', ->
    invoke 'clean'
    invoke 'mkdir'
    invoke 'copy_files'
    invoke 'compile'
    invoke 'deploy'

