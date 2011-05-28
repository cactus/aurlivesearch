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
mkcoffee = (str) ->
    js = coffee.compile(str, {bare: true})
    js.trim()

mkugly = (str) ->
    ast = uglifyjs.parser.parse(str)
    ast = uglifyjs.uglify.ast_mangle(ast)
    ast = uglifyjs.uglify.ast_squeeze(ast, {show_copyright:false})
    js = uglifyjs.uglify.gen_code(ast)
    js.trim()

## options
option '-n', '--dry-run', 'dry run for deploy'

## cake tasks
task 'clean', 'clean dist dir', ->
    exec 'rm -rf ./dist', (error) ->
        console.log('could remove ./dist dir') if error?
        
task 'compile', 'compile the whole thing', ->
    lc =
      AURSEARCHVER: fs.readFileSync('VERSION', 'utf-8').trim()
      bp_screen_css: fs.readFileSync('static/bp.screen.css', 'utf-8').trim()
      icanhazjs: mkugly(fs.readFileSync('src/ICanHaz.js', 'utf-8'))
      dotimeout: fs.readFileSync('src/jquery.ba-dotimeout.min.js', 'utf-8')
      modernizrjs: fs.readFileSync('src/modernizr.min.js', 'utf-8').trim()
      search_coffee: mkugly(mkcoffee(fs.readFileSync('src/search.coffee', 'utf-8')))
      inline_css: fs.readFileSync('src/screen.css', 'utf-8').trim()

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
    exec_str = "rsync -e 'ssh -S none' #{rsync_extra_args} -avzc --delete-after dist/ #{jdata.prod_host_loc} 2>&1"
    console.log(exec_str)
    rsync_child = exec exec_str
    rsync_child.stdout.on 'data', (data) -> console.log(data.trim())
