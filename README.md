# cbqn-win-docker-build
Build CBQN for Windows with Docker

## Usage
Build with:
```sh
docker build -t wbqn .
```
Then you can get BQN.exe and the required .dll's by:
```sh
docker run -v .\:/opt/mount --rm -d wbqn
```

## License
MIT.  
This repo only covers the build process. No binary is distributed.  
c.f. [this repo](https://github.com/actalley/WinBQN/releases), which has their respective licenses attached.
