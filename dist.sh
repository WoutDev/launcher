hash sha1sum &> /dev/null
if [ $? -eq 1 ]; then
        echo "sha1sum not found"
        exit 1
fi

hash pack200 &> /dev/null
if [ $? -eq 1 ]; then
        echo "pack200 not found - is java installed?"
        exit 1
fi

rm -rf ./dist
mkdir -p ./dist

cp build/libs/launcher.jar ./dist/launcher.jar
if [ ! -f "./dist/launcher.jar" ]; then
	echo "No launcher.jar, `gradle build` first?"
	exit 1
fi

cd ./dist
lzma launcher.jar
rm -f launcher.jar
HASH=`sha1sum launcher.jar.lzma | cut -d" " -f1`
mv launcher.jar.lzma $HASH
echo $HASH > launcher.sha1
