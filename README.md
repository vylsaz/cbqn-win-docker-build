# cbqn-win-docker-build
Build [CBQN](https://github.com/dzaima/CBQN) for Windows with Docker

## Usage
`cd` to the folder where you can find this README and Dockerfiles. 

For example, if you want to call your image "winbqn", you want to build with:

```bat
docker build --pull --rm -t winbqn "."
```
You can pass in arguments by adding `--build-arg ARG=VALUE` to the command. The arguments are:
- `BRANCH`, the git branch of dzaima/CBQN to clone from, default: `develop`
- `NATIVE`, should all instructions supported by the local machine be enabled, default: `1`
- `VERSION`, the version to report by CBQN, default: `""` (use commit hash)
- `DEBUG`, should sanity checks and debug symbols be enabled, default: `0`

Then, you can get BQN.exe by:
```bat
docker run -v ".:/opt/mount" --rm -d winbqn
```

Finally, you can remove the image by:
```bat
docker rmi winbqn
```

## License
The BQN logo (BQN.ico) is licensed ISC. Other files are licensed MIT.  

Under `licenses/` are licenses to be distributed with the CBQN binary.

CBQN is dual-licensed LGPLv3 and MPL2, you can choose one.