until [ $? -gt 0 ]; do
  haxelib list | cut -d : -f1 | haxelib remove 
done