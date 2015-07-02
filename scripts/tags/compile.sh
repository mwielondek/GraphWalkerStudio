cd $(dirname $0)
find *.tag -type f -print | sed 'p;s/\(.*\).tag/js\/\1.js/' | xargs -n2 riot -m 
