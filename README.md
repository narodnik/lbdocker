We now have a docker image to easily cross compile applications with libbitcoin and Qt for Android phones.

# What is Docker?

Docker is a lightweight VM that runs a virtualized environment that is relatively responsive to power up. It isn’t a full operating system, but an abstraction layer – like a kind of advanced chroot.

These instructions use Arch but should work on all platforms.

## 1. Install Docker:

    # pacman -S docker

## 2. Make sure Docker is running.

    # systemctl start docker

## 3. Download the test application and unpack it.

    $ cd /tmp/
    $ wget https://polyteknik.org/test1.zip
    $ unzip test1.zip

## 4. Run the docker image

    $ docker run -ti --rm -v /tmp/test1:/test1 narodnik/dw

Explanation of the command:

* -t means open a TTY socket 
* -i means there will be interaction 
* --rm means remove the container after we exit 
* -v /tmp/test1:/test1 will mount /tmp/test1 as a volume at /test1 inside the container. 
* narodnik/dw is my username/repo on hub.docker.com. See https://hub.docker.com/r/narodnik/dw/ 

## 5. You are now inside the docker virtualized environment. Compile the application and exit the environment.

    user@72d49e4d4ae3:~$ cd /test1/
    user@72d49e4d4ae3:/test1$ ./compile.sh
    …
    [CTRL-D]

The first time you run this, it will take a long while because it downloads gradle into the project directory.

## 6. Push the Android APK to the phone and test.

    $ cd /tmp/test1/build/build/outputs/apk/
    $ adb install -r build-debug.apk

Note: next time you install, you will get an error INSTALL_FAILED_UPDATE_INCOMPATIBLE and something about signatures. You must delete the app off your phone for all users before installing again. You can do this in Settings → Apps → test1 (scroll down) → click hamburger (top right three dots) → Uninstall for all users

## 7. Run the application.

Navigate to test1 in your list of applications. Swipe right to Page 2 to see the genesis block hash generated by libbitcoin.

