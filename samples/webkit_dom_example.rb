
#       webkit_dom_example.rb
             
#		(The MIT License)
#
#        Copyright 2011 Matt Mesanko <tulnor@linuxwaves.com>
#
#		Permission is hereby granted, free of charge, to any person obtaining
#		a copy of this software and associated documentation files (the
#		'Software'), to deal in the Software without restriction, including
#		without limitation the rights to use, copy, modify, merge, publish,
#		distribute, sublicense, and/or sell copies of the Software, and to
#		permit persons to whom the Software is furnished to do so, subject to
#		the following conditions:
#
#		The above copyright notice and this permission notice shall be
#		included in all copies or substantial portions of the Software.
#
#		THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
#		EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
require 'rubygems'
require 'ffi'

require File.join(File.dirname(__FILE__),'..','lib','JS')
require File.join(File.dirname(__FILE__),'..','lib','JS','props2methods')
require File.join(File.dirname(__FILE__),'..','lib','JS','webkit')


w = Gtk::Window.new()
v = WebKit::WebView.new

v.load_html_string("<!doctype html><html><body onclick=\"baz(this);\"></body></html>",nil)
w.add v
w.show_all


def ruby_do_dom ctx
  globj = ctx.get_global_object

  
  f=JS::Object.new ctx  do |this,*o|
    p 1
    nil;
  end
  
  globj['baz'] = f

  doc = globj['document']

  body = doc['getElementsByTagName'].call('body')[0]
  ele = doc['createElement'].call('div')
  ele['innerHTML'] = "Click any where ..."

  body['appendChild'].call(ele)

end

w.signal_connect('delete-event') do 
  Gtk.main_quit
end

v.signal_connect('load-finished') do |v,f|
  ruby_do_dom(f.get_global_context)
end

Gtk.main
