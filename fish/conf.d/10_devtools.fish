if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv fish | source
end

if command -q zoxide
    set -gx _ZO_FZF_CMD fzf
    set -gx _ZO_FZF_OPTS "--height 40% --reverse"
    zoxide init fish --cmd cd | source
end

if command -q fnm
    fnm env --use-on-cd --shell fish | source
end

# OpenJDK (Homebrew). Keg-only, so it is not on PATH by default.
# 21, not the 17 also installed: @capacitor/android's build.gradle sets
# sourceCompatibility/targetCompatibility to VERSION_21, so a 17 JAVA_HOME
# fails the android build with "invalid source release: 21".
set -l __jdk /opt/homebrew/opt/openjdk@21
if test -d $__jdk
    set -gx JAVA_HOME $__jdk/libexec/openjdk.jdk/Contents/Home
    fish_add_path $__jdk/bin
end

# Android SDK (Homebrew `android-commandlinetools` cask). Gradle finds the SDK
# via ANDROID_HOME; without it the Capacitor android/ build fails with
# "SDK location not found". platform-tools on PATH gives adb.
set -l __android_sdk /opt/homebrew/share/android-commandlinetools
if test -d $__android_sdk
    set -gx ANDROID_HOME $__android_sdk
    set -gx ANDROID_SDK_ROOT $__android_sdk
    fish_add_path $__android_sdk/platform-tools
    fish_add_path $__android_sdk/cmdline-tools/latest/bin
    # emulator lives outside platform-tools and used to reach PATH only via a
    # one-off `fish_add_path` recorded in fish_variables; declared here so it
    # survives a fresh fish_variables.
    test -d $__android_sdk/emulator; and fish_add_path $__android_sdk/emulator
end
