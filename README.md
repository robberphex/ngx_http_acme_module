# Let's Encrypt module for Nginx

## Introduction

[TODO]

## Dependencies

### Makefile dependencies

To build this module you need all the tools installed which you would also need to
build the Nginx server alone. In addition you need `curl` if you download the source code
of Nginx using `make source` (recommended).

### Libraries

The module uses libcurl for making the HTTP calls to the ACME server and libjansson for
parsing and creating the JSON strings according to the ACME protocol.

## Installation

  0. install `libpcre3-dev`,`libssl-dev`,`zlib1g-dev`,`libcurl4-openssl-dev`,`libjansson-dev` if you are on Debian.

  1. Download the NginX source code using:
        ```shell
        make source
        ```
  2. Configure, build and install the server with the module:
        ```shell
        make install
        ```

      With this step the server is compiled and installed in the `./run` directory.
      Don't worry, nothing is installed on your system outside this directory.
      
  3. Run the server:
        ```shell
        make run
        ```

      You can later stop the server with:
        ```shell
        make kill
        ```

## Configuration

  * The build process and the directories can be configured in the first few lines of
    the [Makefile](Makefile).

  * The server will run with a copy of the configuration file [example/nginx.conf](example/nginx.conf)
