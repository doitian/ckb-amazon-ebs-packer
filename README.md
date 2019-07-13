# CKB AMI Builder

## Get Started

```
cp variables.json.example variables.json
```

Edit `variables.json`. The `ba_arg` is the block assember arg for secp256k1 lock.

Now, build the ami:

```
packer build -var-file=variables.json packer.json
```

Then just start instances to mine. Remember to allocate enough disk space for the new instances.

It is easy to update `pckage.json` to build other images, such as Virtual Box. See the [docs](https://www.packer.io/docs/builders/index.html) of packer.
