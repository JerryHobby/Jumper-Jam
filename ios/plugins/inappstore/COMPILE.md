### Sites ###

https://github.com/godotengine/godot-ios-plugins

https://docs.godotengine.org/en/stable/tutorials/platform/ios/ios_plugin.html

- - - -

1. Clone the plugin repository and submodules. This grabs the source code of Godot Engine as well. If you don't need to do that again then clone without `--recursive` around your godot folder or symlink/alias it in.

```bash
git clone --recursive https://github.com/godotengine/godot-ios-plugins.git
```

2. Match the godot repo within to your desired version. As of right now the godot version within is 3.5. Since this guide is intended for 4.0 I imagine you will want to change this. We start by hopping into the godot directory, updating the HEAD with a `fetch` command, then listing the target versions by just saying `tag`. After we are certain on the target version, we `checkout` to it. Replace `git checkout 4.0.2-stable` with your desired version. 

```bash
cd godot
git fetch
git tag
git checkout 4.0.2-stable
```

3. Now we compile the header files, which apparently get compiled first. Run the following command, then once you start seeing [numbers%] blah blah blah, you can cancel the compilation with Control + C. On macOS default terminal, it truly is the Control Key and not the Command Key.

```bash
scons platform=ios target=editor
```

4. Next we generate a static `.a` library within the godot folder. Replace `plugin=inappstore` with your desired plugin. It can be `apn, arkit, camera, gamecenter, inappstore,` or `photo_picker`. Also replace version with your desired version. Do not interrupt this process like before.

```bash
scons target=editor arch=arm64 simulator=no plugin=inappstore version=4.0.2
```

5. Leave the godot directory then access the scripts from the repo root. Replace `inappstore` with your desired plugin, but keep `4.0` as is. Currently the script doesn't support any other input.

```bash
cd ..
./scripts/generate_static_library.sh inappstore debug 4.0
```

then

```bash
./scripts/generate_xcframework.sh inappstore debug 4.0
```

6. We now start the process again, but for the other target types. It's awkward because the scons target types in godot expect `editor, template_release, or template_debug`, whereas the provided scripts for making the .a and xcframework libraries expect `debug, release, or release_debug`. I don't think you need to recompile the Godot Engine (Step 3) for each target as well, just the plugin and the two scripts. Your terminal should something like this...

```bash
cd godot
scons target=template_debug arch=arm64 simulator=no plugin=inappstore version=4.0.2
cd ..
./scripts/generate_static_library.sh inappstore release_debug 4.0
./scripts/generate_xcframework.sh inappstore release_debug 4.0
cd godot
scons target=template_release arch=arm64 simulator=no plugin=inappstore version=4.0.2
cd ..
./scripts/generate_static_library.sh inappstore release 4.0
./scripts/generate_xcframework.sh inappstore release 4.0
```

7. Prepare your personal project for the plugins. On the root folder of your project make a folder called `ios` and a folder within that called `plugins`. It should look similar to the file structure of the demo project.
8. Return to the root folder of the godot-ios-plugins repo. Open the `bin` folder and try to ignore all the individual files. Select and copy just the folders to the clip board. The folder name scheme is plugin.target.xcframework.

```
inappstore.debug.xcframework
inappstore.release_debug.xcframework
inappstore.release.xcframework
```

9. Navigate back or up, then go into the `plugins` folder. You should see all the folders for each plugin. Each of these contains a Readme on __How to Use__ each plugin in code, as well as a `.gdip` file and a bunch of other stuff. Hop into the `inappstore` folder or your desired plugin. Then paste in the folders from clipboard.
10. Now select the `.gdip` file, the Readme, and the folders we just copied in and copy those to your clipboard. Return to the `ios/plugins` folder you made in Step 7, make a new folder named for your plugin, then paste within it.

If you encounter "Invalid Plugin Config File plugin.gdip", then you too now share the confusing experience that consumed a large part of my day. Initially when I followed along the official instructions [Here](https://github.com/godotengine/godot-ios-plugins#instructions) I encountered a lot of issues, and had great difficulty finding answers on this error code. Eventually I tried using the Released 3.5 plugins, and the error went away, but then I couldn't export to XCODE with the plugin enabled. Something about it failing to run Ld /blah/blah/blah/blah. What finally worked was the instructions I have provided you now. I at first assumed I would only need the `template_debug` and `release_debug` targets. It wasn't until I went ahead and just compiled all the different targets out of desperation that it finally worked. 

If you encounter an issue when running the scripts that it failed to copy `A` to `B` because `B` exists, you have to delete `B` then try again. This will probably happen if you, trying to get the plugin working, are checking out the godot repo to different versions and going through the steps again.

This whole thing has a high chance of being read with a rude tone, made out of spite. While I concede this was a frustrating experience, I still ultimately appreciate all the work that has been done to get to this point. Also, from what I understand, this whole system is probably on low priority. I listened in a bit on the 2023 GDC Godot talks, and I'm guessing this whole thing will become a better experience if/when Firebase is officially integrated. Godot 4.0 in general seems targeted for Desktop/PC applications at the moment too.
