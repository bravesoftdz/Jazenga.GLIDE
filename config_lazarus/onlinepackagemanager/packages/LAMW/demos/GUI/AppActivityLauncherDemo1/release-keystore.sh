export JAVA_HOME=/Program Files (x86)/Java/jdk1.7.0_21
cd /android-neon/eclipse/workspace/AppActivityLauncherDemo1
keytool -genkey -v -keystore AppActivityLauncherDemo1-release.keystore -alias appactivitylauncherdemo1aliaskey -keyalg RSA -keysize 2048 -validity 10000 < /android-neon/eclipse/workspace/AppActivityLauncherDemo1/appactivitylauncherdemo1keytool_input.txt
