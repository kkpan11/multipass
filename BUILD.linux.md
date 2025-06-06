# Build instructions for Linux

## Environment Setup

### Build dependencies

```
cd <multipass>
sudo apt install devscripts equivs
mk-build-deps -s sudo -i
```

## Building

First, go into the repository root and get all the submodules:

```
cd <multipass>
git submodule update --init --recursive
```

If building on arm, s390x, ppc64le, or riscv, you will need to set the `VCPKG_FORCE_SYSTEM_BINARIES`  environment
variable:

```
export VCPKG_FORCE_SYSTEM_BINARIES=1
```

Then create a build directory and run CMake.

```
mkdir build
cd build
cmake ../
```

This will fetch all necessary content, build vcpkg dependencies, and initialize the build system. You can also specify
the `-DCMAKE_BUILD_TYPE` option to set the build type (e.g., `Debug`, `Release`, `Coverage`, etc.).

Finally, to build the project, run:

```
cmake --build . --parallel
```

Please note that if you're working on a forked repository that you created using the "Copy the main branch only" option,
the repository will not include the necessary git tags to determine the Multipass version during CMake configuration. In
this case, you need to manually fetch the tags from the upstream by running
`git fetch --tags https://github.com/canonical/multipass.git` in the `<multipass>` source code directory.

## Run the Multipass daemon and client

First, install Multipass's runtime dependencies. On AMD64 architecture, you can do this with:

```
sudo apt update
sudo apt install libgl1 libpng16-16 libqt6core6 libqt6gui6 \
    libqt6network6 libqt6widgets6 libxml2 libvirt0 dnsmasq-base \
    dnsmasq-utils qemu-system-x86 qemu-utils libslang2 iproute2 \
    iptables iputils-ping libatm1 libxtables12 xterm
```

Then run the Multipass daemon:

```
sudo <multipass>/build/bin/multipassd &
```

Copy the desktop file that Multipass clients expect to find in your home:

```
mkdir -p ~/.local/share/multipass/
cp <multipass>/data/multipass.gui.autostart.desktop ~/.local/share/multipass/
```

Optionally, enable auto-complete in Bash:

```
source <multipass>/completions/bash/multipass
```

Now you can use the `multipass` command from your terminal (for example
`<multipass>/build/bin/multipass launch --name foo`) or launch the GUI client with the command
`<multipass>/build/bin/multipass.gui`.
