require 'rubygems'
require 'sinatra'
require 'nkf'

$KCODE = 'UTF8'

get "/" do 
  $index ||= DATA.read
end

post "/" do
  body = params[:body]
  
  f = File.open('tempfile','w')
  f.puts(NKF.nkf('-e',body))
  f.close
  
  begin
    ["echo 'x' | platex #{f.path}", "dvipdfmx #{f.path}.dvi"].each{ |cmd|
      result = `#{cmd}`
      raise result if $? != 0
    }

    response['Content-Type'] = 'application/pdf'
    content = open("#{f.path}.pdf").read
    Dir.glob('tempfile*').each{ |file| File.unlink(file)}
    content

  rescue => e
    Dir.glob('tempfile*').each{ |file| File.unlink(file)}
    response['Content-Type'] = 'text/plain'
    e.message
  end
end

__END__
<html>
  <head>
    <title>sinatex</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body>
    <h1>sinatex</h1>
    <form action="/" method="post">
      <textarea name="body"  rows="40" cols="80"></textarea><br>
      <input type="submit" value="Send">
    </form>
	<h2>author</h2>
	<a href="http://twitter.com/ymzkey">ymzkey(sinatex)</a>
  </body>
</html>
