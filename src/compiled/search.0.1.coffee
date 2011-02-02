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

qurl = 'http://aur.archlinux.org/rpc.php?callback=?'
doajaxy = () ->
    $('#response').empty()
    $('#counter span').empty().text(0)
    if $('#q').val().length < 3
        $('#ajax-loading').hide()
        err_msg = { 
            short_msg: "query too short", 
            long_msg: "must be at least 3 characters" 
        }
        $('#response').append(ich.error_tpl(err_msg))
        return false
    submit_data = { "type": "search", "arg": $('#q').val() }
    $.getJSON(qurl, submit_data, (data, txtStatus, req) ->
        if !data or data == ""
            err_msg = { short_msg: "No Results" }
            $('#response').append(ich.error_tpl(err_msg))
        else if data.type == "error"
            err_msg = { short_msg: data.results }
            $('#response').append(ich.error_tpl(err_msg))
        else
            packages = for index, obj of data.results
                {pkg: obj}
            $('#response').append(ich.packages_tpl({packages: packages}))
            $('#counter span').text(data.results.length)
        $('#ajax-loading').hide()
    )
    return false

ajaxy_firing_pin = (callable, delay) =>
    # have to use css here, because show does display: block
    $('#ajax-loading').css('display', 'inline')
    # only fire callable once every X timeperiod
    clearTimeout(@ajaxy_timeout)
    @ajaxy_timeout = setTimeout(callable, delay)

setup_ajaxy = () ->
    timeout_len = 500
    $('#searchform form').ajaxError((e, xhr, settings, exception) ->
        $('#response').empty()
        err_msg = { 
            short_msg: "Error fetching data", 
            long_msg: exception 
        }
        $('#ajax-loading').hide()
        $('#response').append(ich.error_tpl(err_msg))
    )

    $('#searchform form input').keyup((eventObj) => 
        # only fire event if content length has changed
        @oldlen or= 0
        newlen = eventObj.target.value.length
        if newlen != @oldlen
            @oldlen = newlen
            ajaxy_firing_pin(doajaxy, timeout_len)
    )

$(document).ready(->
    $('#searchform form').submit(-> false)
    setup_ajaxy();
    $('#searchform form input').focus()
)