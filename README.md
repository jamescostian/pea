# pea: Prepare Encrypted Auto-boot

> Impeads poweroff until pea'd

Problem: with full-disk encryption, you cannot reboot your machine remotely
since it will ask for a password during boot.

Existing solution: install a SSH server in the initial ramdisk
https://benediktkr.github.io/ops/2015/05/01/remote-fde.html

Drawbacks: ssh identity is stored unencrypted.

## Proposal

Before a remote reboot, you must run the command `pea` to generate a
one-time token (OTP) which is used during startup to descrypt the root partition.

After a successful boot, the current OTP is invalidated. The OTP is shortlived.

Drawbacks: if you accidentally reboot without running `pea` first, sucks to suck. Get in a car.

## Setup

An unencrypted partition to hold the OTP is mounted at `/boot`.
The OTP is a LUKS keyfile called `/boot/ot.pea`.

## Components

`pead`: systemd service (daemon) which inhibits poweroff until `pea` is ran

`pea`: command to generate `/boot/ot.pea`

`peat`: helper script to check arguments
