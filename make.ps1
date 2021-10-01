$root = $PsScriptRoot
cd $root
'ananke', 'categories', 'images', 'posts', 'tags' | Remove-Item -force -recurse
'404.html', 'index.html', 'index.xml', 'sitemap.xml' | Remove-Item 

cd $root\src\stejblog
Remove-Item public -recurse -force

$env:HUGO_ENV = "production" # needed, because this env variable is checked inside themes\ananke\layouts\_default\baseof.html and is used when rendering ROBOTS
hugo -D
cd public
gci | Copy-Item -dest ..\..\.. -recurse