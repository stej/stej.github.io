$root = $PsScriptRoot
cd $root
'ananke', 'categories', 'images', 'posts', 'tags' | Remove-Item -force -recurse
'404.html', 'index.html', 'index.xml', 'sitemap.xml' | Remove-Item 

cd $root\src\stejblog
hugo -D
cd public
gci | Copy-Item -dest ..\..\.. -recurse