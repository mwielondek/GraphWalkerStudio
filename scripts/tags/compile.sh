cd $(dirname $0)
# if no args given, compile all tag files in folder
if [ $# -eq 0 ]
then 
  find *.tag -type f -print | sed 'p;s/\(.*\).tag/js\/\1.js/' | xargs -n2 riot -m 
else
  echo $1 | gsed 's/.*\///' | gsed 'p;{s/^/js\//;s/\.tag/\.js/}' | xargs -n2 riot -m
fi
