require 'open-uri'

desc 'Compile editor.html'
task :editor do
  sharejs = open('https://github.com/usecanvas/sharejs-wrapper/raw/master/dist/index.js').read.chomp
  editor = File.read('CanvasText/Resources/editor.js').chomp

  html = %Q{<!DOCTYPE html>
<html lang="en-US">
  <head>
    <meta charset="utf-8">
    <title>Canvas</title>
    <script>
#{sharejs}

////////////////////////////////////////////////////////////////////////////////

#{editor}
    </script>
  </head>
  <body></body>
</html>
}

  file = File.new('CanvasText/Resources/editor.html', 'w')
  file.write(html)
  file.close
end
