# seed-nodejs-docker

Code template to run a NodeJS development environment in Docker or Kubernetes

## Usage

Start the development environment with

For Docker:

```bash
npm run dev:docker
```

For Kubernetes:

```bash
npm run dev:kubernetes
```

## Principles

The related scripts and resources are in the `_dev` folder. Should work of the box for a proof of concept but can be constomized. This is designed so that the `_dev` folder can be copied to any repository that need to use the same procedure. All other resources in this repository are for example purposes and have to be customized for each projects.

The container

- is executed with the same user as the current command line user .
- only share 1 volume with the system: the current service folder.
- expose 1 port (3000 mapped to a random port on the system)
