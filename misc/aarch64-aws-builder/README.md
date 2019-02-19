# aarch64-aws-builder

Run `makepkg` for aarch64 architecture using the AWS EC2 `a1` instance family (AWS Graviton)

## Prerequisite

- Packer

## Configure

Create your `.env` file; refer to `.env.example` for details

## Prepare builder AMI

```
./prepare.sh
```

Runs packer build for `builder.json`, which creates Ubuntu based AMI includes Arch Linux ARM rootfs.

## Run builder AMI

```
./build.sh ../../aur-sorah/PKGBUILDs/mitamae
```

Runs packer build to launch the builder AMI, run `makepkg`, retrieve the built packages, and terminate the instance.

## Push

```
./push.sh out/stage/*.xz
```

Emulates `guzuta omakase build` behavior:

1. Fetch repository files from S3
2. run `guzuta repo-add`, `guzuta files-add`
3. Put the files to S3
