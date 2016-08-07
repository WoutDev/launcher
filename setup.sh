hash lzma &> /dev/null
if [ $? -eq 1 ]; then
	echo "lzma not found"
	exit 1
fi

hash java &> /dev/null
if [ $? -eq 1 ]; then
	echo "java not found"
	exit 1
fi

hash unpack200 &> /dev/null
if [ $? -eq 1 ]; then
	echo "unpack200 not found - is java installed?"
	exit 1
fi

hash git &> /dev/null
if [ $? -eq 1 ]; then
	echo "git not found"
	exit 1
fi

hash unzip &> /dev/null
if [ $? -eq 1 ]; then
	echo "unzip not found"
	exit 1
fi

hash ant &> /dev/null
if [ $? -eq 1 ]; then
	echo "ant not found"
	exit 1
fi

rm -rf ./src
rm -rf ./src-decomp
rm -rf ./setup
mkdir -p ./setup
cd ./setup

# retrieve fernflower
git clone https://github.com/fesh0r/fernflower.git
cd fernflower
ant dist
cp fernflower.jar ../
cd ..

# retrive the launcher from Mojang
wget https://s3.amazonaws.com/Minecraft.Download/launcher/launcher.pack.lzma
lzma -d ./launcher.pack.lzma
unpack200 ./launcher.pack ./launcher.jar

# fernflower
mkdir -p ./launcher
java -jar fernflower.jar -dgs=1 -udv=0 ./launcher.jar ./launcher
cd launcher
unzip ./launcher.jar
rm -f ./launcher.jar
cd ..
cp -R ./launcher ../src-decomp
cd ..

# dependencies
rm -rf ./src-decomp/javax
rm -rf ./src-decomp/org/apache/commons/lang3
rm -rf ./src-decomp/org/apache/commons/io
rm -rf ./src-decomp/org/apache/commons/codec
rm -rf ./src-decomp/org/apache/logging/log4j
rm -rf ./src-decomp/com/google/common
rm -rf ./src-decomp/com/google/thirdparty
rm -rf ./src-decomp/com/google/gson
rm -rf ./src-decomp/com/mojang/authlib
rm -rf ./src-decomp/joptsimple
rm -rf ./src-decomp/META-INF/

###
## Below looks actually awful. Can we fix this? Can we make this not a thing?
## Anyone who's smarter than me please tell me
###

## fix FileFilter
sed -i '1 aimport java.io.FileFilter;' ./src-decomp/net/minecraft/launcher/Launcher.java
sed -i -e 's/listFiles(/listFiles((FileFilter)/g' ./src-decomp/net/minecraft/launcher/Launcher.java
sed -i -e 's/listFiles((FileFilter))/listFiles()/g' ./src-decomp/net/minecraft/launcher/Launcher.java
sed -i -e 's/FileUtils.listFiles((FileFilter)/FileUtils.listFiles(/g' ./src-decomp/net/minecraft/launcher/Launcher.java

## fix final GameProfile
sed -i -e 's/final GameProfile var6 = null;//g' ./src-decomp/net/minecraft/launcher/ui/popups/login/LogInForm.java
sed -i -e 's/public void tryLogIn() {/public void tryLogIn() {GameProfile var6 = null;/g' ./src-decomp/net/minecraft/launcher/ui/popups/login/LogInForm.java
sed -i -e 's/this.popup.getMinecraftLauncher().getLauncher().getVersionManager().getExecutorService().execute(new Runnable() {/final GameProfile _var6 = var6; this.popup.getMinecraftLauncher().getLauncher().getVersionManager().getExecutorService().execute(new Runnable() {/g' ./src-decomp/net/minecraft/launcher/ui/popups/login/LogInForm.java
sed -i -e 's/LogInForm.this.authentication.selectGameProfile(var6);/LogInForm.this.authentication.selectGameProfile(_var6);/g' ./src-decomp/net/minecraft/launcher/ui/popups/login/LogInForm.java

## fix ExceptionalFutureTask
sed -i -e 's/super(var2);/super(var1);/g' ./src-decomp/com/mojang/launcher/updater/ExceptionalThreadPoolExecutor.java
sed -i -e 's/super(var2, var3);/super(var1, var2);/g' ./src-decomp/com/mojang/launcher/updater/ExceptionalThreadPoolExecutor.java

## fix LowerCaseEnumTypeAdapterFactory
sed -i -e 's/return new TypeAdapter() {/return new TypeAdapter<T>() {/g' ./src-decomp/com/mojang/launcher/updater/LowerCaseEnumTypeAdapterFactory.java
sed -i -e 's/return var4.get(var1.nextString());/return (T) var4.get(var1.nextString());/g' ./src-decomp/com/mojang/launcher/updater/LowerCaseEnumTypeAdapterFactory.java

## fix newHashSet
sed -i '1 aimport java.util.HashSet;' ./src-decomp/net/minecraft/launcher/updater/CompleteMinecraftVersion.java
sed -i -e 's/Sets.newHashSet/new HashSet/g' ./src-decomp/net/minecraft/launcher/updater/CompleteMinecraftVersion.java
sed -i '1 aimport java.util.HashSet;' ./src-decomp/net/minecraft/launcher/profile/Profile.java
sed -i -e 's/DEFAULT_RELEASE_TYPES = Sets.newHashSet/DEFAULT_RELEASE_TYPES = (Set<MinecraftReleaseType>)Sets.newHashSet/g' ./src-decomp/net/minecraft/launcher/profile/Profile.java
sed -i -e 's/Sets.newHashSet((Object\[\])/Sets.newHashSet(/g' ./src-decomp/net/minecraft/launcher/profile/Profile.java

## other fixes
sed -i -e 's/withSysOutFilter(new Predicate() {/withSysOutFilter(new Predicate<String>() {/g' ./src-decomp/net/minecraft/launcher/game/MinecraftGameRunner.java
sed -i -e 's/, new Comparator() {/, new Comparator<VersionSyncInfo>() {/g' ./src-decomp/net/minecraft/launcher/updater/MinecraftVersionManager.java
sed -i -e 's/getLoadWorker().stateProperty().addListener(new ChangeListener()/getLoadWorker().stateProperty().addListener(new ChangeListener<State>()/g' ./src-decomp/net/minecraft/launcher/ui/tabs/website/JFXBrowser.java
sed -i -e 's/return var5;/return (T) var5;/g' ./src-decomp/net/minecraft/hopper/HopperService.java
sed -i -e 's/this.natives.put(var4.getKey(), var4.getValue());/this.natives.put((OperatingSystem) var4.getKey(), (String) var4.getValue());/g' ./src-decomp/net/minecraft/launcher/updater/Library.java
sed -i -e 's/QUEUES.put(var4, var6);/QUEUES.put(var4, (LinkedBlockingQueue) var6);/g' ./src-decomp/com/mojang/util/QueueLogAppender.java
sed -i -e 's/var4.get("profiles"), (new TypeToken() {/var4.get("profiles"), (new TypeToken<Map<String, Profile>>() {/g' ./src-decomp/net/minecraft/launcher/profile/ProfileManager.java

# git init
mkdir -p ./src
cd ./src
git init
cd ..
cd ./src-decomp
git init
git add .
git config user.name "SquidHQ"
git config user.email "git@squidhq.com"
git commit -am 'first commit'
cd ..

# patches
./applyPatches.sh

echo "Done"
