#!/bin/sh

PATH=$PATH:/usr/local/bin
TARGET_DIR="../lib"
JSPATH="../target/*.js"
TFILE="../tmp/out.tmp.$$"

echo "Compiling CoffeeScript"
coffee --compile --output ../target ../src
echo "Copying Libs"
cp ../src/*.js ../target/
echo "Updating Refs"
for f in $JSPATH
do
    sed "s/cs!//g" "$f" > $TFILE && mv $TFILE "$f"
done
echo "Compiling SDK"
rm -rf $TARGET_DIR
node r.js -o build.js


