# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'
require 'nkf'
require 'haml'

$KCODE = 'UTF8'

get "/" do 
  if File.exist?("./files") 
    all_fiels = Dir::entries("./files/")
    @files =  Dir::entries("./files/")[2...all_fiels.size]
  else
    @files = []
  end

  haml :index
end

post "/" do
  if params[:pushed] == "delete"
    if File.exist?("./files/#{params[:filename]}") and params[:filename] != nil
      File.delete("./files/#{params[:filename]}")
    else
      "no file selected"
    end

  elsif params[:pushed] == "upload"
    Dir::mkdir("./files") unless File.exist?("./files")
    save_file = File.join('./files', File.basename(params[:file][:filename]))
    File.open(save_file, 'wb'){|f| f.write(params[:file][:tempfile].read)}

  elsif params[:pushed] == "genelate"
    break if File.exist?("./files") 
    body = params[:body]
    f = File.open('./files/body','w')
    f.puts(NKF.nkf('-e',body))
    f.close
    p "genelate!!!!"

  else
    params[:pushed]
  end
  redirect '/'
end

__END__
@@ index
%html
  %head
    %title sintex
    %meta{"http-equiv" => "Content-Type",:content => "text/html", :charset =>"utf8"}
    %style(type='text/css' href='/application.css')      
  %body
    %h1 sintex
    %br
    %form{:action =>"/",:method => "post",:enctype => "multipart/form-data"}
      %input{:type => "file",:name => "file"}
      %input{:type =>"submit", :name=>"pushed",:value=>"upload"}
      %br
      - @files.each do |item|
        %a{:href => "/files/#{item}"} #{item}
        %input{:type => "hidden",:name=>"filename",:value=>"#{item}"}
        %input{:type => "submit",:value => "delete",:name => "pushed"}
      %br
      %textarea{:name=>"body",:rows=>"40",:cols=>"80"}
      %br
      %input{:type => "submit",:value => "genelate",:name => "pushed"}

    %h2 aouthor
    %a{:href=>"http://www.twitter.com/ymzkey"} ymzkey(sintex)
