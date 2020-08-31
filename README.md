# Introduction to Functional Programming, with Examples in Haskell

**Author:** Ose Pedro

This repository contains a basic implementation of the messaging system that I used as a running example in my ["Introduction to Functional Programming" presentation](https://docs.google.com/presentation/d/1bIBQewtYiaXQy0kvyWsJ3YTIPQMGXIq1hXNsOXZcURI).

## Getting Started

To play around with the messaging system, do the following:

1. **Install Haskell:** follow [these instructions](https://www.haskell.org/platform/).
1. **Download this repository:**
    1. Option 1 (easiest): **Download the zip file:**
        1. Click the "Code" button above, then "Download Zip".
        1. Unzip the file somewhere.
    1. Option 2: **Clone the Git repository:**
        1. If you don't already have Git, use [these instructions](https://git-scm.com/downloads) to get it.
        1. Launch a terminal and run `git clone git@github.com:OsePedro/HaskellIntro.git` to clone this repository.
1. Launch a terminal and navigate to the `HaskellIntro` directory that you downloaded/cloned.
1. Run `ghci` &mdash; this is a REPL (an interactive environment), in which you can execute arbitrary Haskell expressions.
1. Type `:l Demo.hs` to load the code.
1. Type `msgSys1` to view a `MsgSys` that contains a few messages and `User`s.

## Things to Try

1. Open [Demo.hs](Demo.hs) in an editor. If you want syntax highlighting, try:
    - [Visual Studio Code](https://code.visualstudio.com/) with the [Haskell](https://marketplace.visualstudio.com/items?itemName=haskell.haskell) extension;
    - or [Atom](https://atom.io/) with the [language-haskell](https://atom.io/packages/language-haskell) package.
1. Add code that registers two new `User`s to `msgSys1`:
    - (the `initialise` function at the bottom of the file demonstrates how to do this).
1. Reload the file in `ghci` (i.e. run `:l Demo.hs` again), to make sure it compiles.
Feel free to ask me for help if you have any issues.
1. Search for one of these new `User`s by their name:
    - `myUser = findUser msgSys name` (make sure you use the most recent `MsgSys`!).
1. `login` as the other `User`:
    - `myLoggedInUser = login name password msgSys`
1. Reload the file in `ghci`, then `send` a message from your new `LoggedInUser` to your new `User`:
    - If you execute `send message userPair msgSys` in `ghci`, it will show you the new state of the `MsgSys`.
1. Try out some of the functions that we wrote in the presentation, e.g.:
    - `alertOutOfSpace user msgSys`
    - `usedSpace msgSys user`
    - `alertMultiOutOfSpace listOfUsers msgSys`
1. Have a go at the ["homework" 😁](https://docs.google.com/presentation/d/1bIBQewtYiaXQy0kvyWsJ3YTIPQMGXIq1hXNsOXZcURI/edit#slide=id.g9342e8f7da_2_30).
1. [MsgSys.hs](MsgSys.hs) defines the system's basic types and functions, e.g. `MsgSys`, `User`, `send`, etc.
Feel free to look at it &mdash; it's quite short, and you might understand more of it than you'd expect!

## I'm Hooked! Where Can I learn More About Haskell?

- [A Gentle Introduction to Haskell](https://www.haskell.org/tutorial/) &mdash; a short and sweet tutorial.
- [Learn You a Haskell for Great Good](http://learnyouahaskell.com/) &mdash; I've barely read any of this, but what I've seen so far seems good, and it's free to read online.
