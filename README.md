# canextech-assessment

## Build Instructions

There is a Dockerfile which pulls from nvidia's stock version 36.4 jetson-linux-flash container by default.
There is a Makefile with several targets which are executed in that docker container environment.

To build the development/flashing container, run

```
make build
```

To enter the container with a bash shell, run

```
make shell
```


To attempt to flash a stock image to a connected jetson board, run

```
make flash
```
