# cbqn-win-docker-build
Build [CBQN](https://github.com/dzaima/CBQN) for Windows with Docker

## Usage
`cd` to the folder where you can find this README and Dockerfiles. 

Build with:
```bat
docker build --pull --rm -t wbqn "."
```
You can pass in arguments by adding `--build-arg ARG=VALUE` to the command. The arguments are:
- `BRANCH`, the git branch of dzaima/CBQN to clone from, default: `develop`
- `NATIVE`, should all instructions supported by the local machine be enabled, default: `0`
- `VERSION`, the version to report by CBQN, default: `""` (use commit hash)

Then, you can get BQN.exe by:
```bat
docker run -v ".:/opt/mount" --rm -d wbqn
```

## License
The BQN logo (BQN.ico) is licensed ISC. Other files are licensed MIT.  

Under `licenses/` are licenses to be distributed with the CBQN binary.