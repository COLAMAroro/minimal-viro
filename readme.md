# Virology

## How to setup Rust, and the build dependencies

### On Nix enabled systems

Just `nix develop` in the root of the repository.  
It will automatically install the correct version of Rust and all the build dependencies.  
It will also setup the correct linker for Windows  
It also includes Wine, so you can run the Windows build on Linux.  

### On other linux systems

Install Rust and the build dependencies.  
Install `lld` for linking on Windows.  
Run `cargo install xwin` to install the xwin tool.  
Run `xwin --accept-license splat --output .xwin` to fetch the Windows SDK.  
Create the file `.cargo/config.toml` with the following content:  

```toml
[target.x86_64-pc-windows-msvc]
linker = "lld"
rustflags = [
    "-Lnative=.xwin/crt/lib/x86_64",
    "-Lnative=.xwin/sdk/lib/um/x86_64",
    "-Lnative=.xwin/sdk/lib/ucrt/x86_64"
]
```

Installing Wine is optional, but it is recommended.

### On Windows

Install Rust and the build dependencies.  
Install Visual Studio 2019 with the "Desktop development with C++" workload.  

## How to build

`cargo build --target x86_64-pc-windows-msvc --release`

On Linux systems, you can also build for Linux with `cargo build --release`.  
While certain features are not available on Linux, it is still possible to build, to try some things out.  
