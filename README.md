# cbqn-win-docker-build
Build CBQN for Windows with Docker

## Usage
cd to the folder where you can find this README and Dockerfiles. Build with:
```sh
docker build --pull --rm -f "Dockerfile to use" -t wbqn .
```
Then you can get BQN.exe and the required .dll's by:
```sh
docker run -v .\:/opt/mount --rm -d wbqn
```

## License
MIT.  
This repo only covers the build process. No binary is distributed.  
c.f. [this repo](https://github.com/actalley/WinBQN/releases), which has their respective licenses attached.
