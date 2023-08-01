# cbqn-win-docker-build
Build CBQN for Windows with Docker

## Usage
cd to the folder where you can find this README and Dockerfiles. Build with:
```bat
docker build --pull --rm -t wbqn .
```
Then you can get BQN.exe by:
```bat
docker run -v .\:/opt/mount --rm -d wbqn
```

## License
MIT.  
This repo only covers the build process. No binary is distributed.  
c.f. [this repo](https://github.com/actalley/WinBQN/releases), which has their respective licenses attached.
