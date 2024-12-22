# cbqn-win-docker-build
Build [CBQN](https://github.com/dzaima/CBQN) for Windows with Docker

## Usage
`cd` to the folder where you can find this README and Dockerfiles. 

For example, if you want to call your image "winbqn", you want to build with:

```powershell
docker build -t winbqn .
```
You can pass in arguments by adding `--build-arg ARG=VALUE` to the command. The arguments are:
- `BRANCH`, the git branch of dzaima/CBQN to clone from, default: `develop`
- `NATIVE`, should all instructions supported by the local machine be enabled, default: `0`
- `REPLXX`, use replxx for the repl, default: `1`
- `VERSION`, the version to report by CBQN, default: `""` (use commit hash)
- `EXE_OPTS`, other options for build when building the executable, default: `""`
- `DLL_OPTS`, other options for build when building the shared library, default: `""`
- `LIB_OPTS`, other options for build when building the static library, default: `""`

Then, you can get bqn.zip by:
```powershell
docker run -v ${PWD}:/out --rm -d winbqn cp /build/out/bqn.zip /out
```

Finally, you can remove the image by:
```powershell
docker rmi winbqn
```

## License
The BQN logo (BQN.ico) is licensed ISC. Other files are licensed MIT.  

Under `licenses/` are licenses to be distributed with the CBQN binary.

CBQN is dual-licensed LGPLv3 and MPL2, you can choose one.