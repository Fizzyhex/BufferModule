[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity)

![Superball Example](/images/SuperballGif.gif)

## Documentation

[The documentation can be found here](https://virshal.github.io/BufferModule/).

## About

A system built to help combat input latency when using physics on Roblox. This system is built using the principles described by TheNexusAvenger in [this article on his website](https://www.thenexusavenger.io/article/6/making-no-latency-projectile-weapons-on-roblox).

## Why use this implementation?

1. Support for multiple items inside of the Buffer
2. Security features that help protect against abuse of the system

## How does this work?

This module creates a Folder which stores all items added to the Buffer via the server, such as projectiles. When an item is added to the buffer it will have its [NetworkOwnership](https://developer.roblox.com/articles/Network-Ownership) assigned to whichever player is given ownership over the buffer (e.g the player who is holding a weapon).

Buffered items are held suspended far away from the play area. When the client needs to create a new projectile, such as when the player activates a weapon, instead of creating a new Instance we instead pull an existing one from the Buffer. Since the Instance already exists and we have NetworkOwnership over it, we can instantly start controlling the physics of the item.

## Caveats

As nice as the system sounds, it does come with some clear caveats that may influence if you decide to use this system over something else:

- This method is not supported natively by the Roblox Engine. This comes with some weird downsides, such as how buffered items need to be stored as descendants of the Workspace, or how buffered items cannot be Anchored until they are removed from the buffer.
- The client has control over the physics of items in the buffer. This comes with the usual security concerns of giving the client [NetworkOwnership](https://developer.roblox.com/articles/Network-Ownership) over parts.

## Getting Started

### Install

1. Grab the latest release from the [releases tab](https://github.com/Virshal/BufferModule/releases) on GitHub.
2. Insert the module somewhere accessible on the server/client, such as inside of `ReplicatedStorage`.
3. Review the Configuration module under `BufferModule.Configuration` and tweak it to your liking.

### Usage

See the [documentation](https://virshal.github.io/BufferModule/) to find out how to implmenet the system in your own experiences. An example place can be found in the [releases tab](https://github.com/Virshal/BufferModule/releases).

---

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/J3J8AN7RG)
