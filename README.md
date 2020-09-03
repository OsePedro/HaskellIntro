# Introduction to Functional Programming, with Examples in Haskell

**Author:** Ose Pedro

This repository contains a basic implementation of the messaging system that I used as a running example in my ["Introduction to Functional Programming" presentation](https://docs.google.com/presentation/d/1bIBQewtYiaXQy0kvyWsJ3YTIPQMGXIq1hXNsOXZcURI).

## Setup

### Option 1: Run it Online

The easiest way to start playing around with the messaging system is to use [this repl.it installation](https://repl.it/@OsePedro/HaskellIntro).
If you want to save your changes, you should probably sign up for a free account (I don't know how long they'll keep your changes for if you don't).

### Option 2: Run it Locally

If you'd rather play with a local copy of the code, you'll need to do the following:
1. **Install Haskell:** follow [these instructions](https://www.haskell.org/platform/).
    - I've only done this in Ubuntu, where it's as simple as launching a terminal and running

          sudo apt-get update
          sudo apt-get install haskell-platform

    - The Mac OS X installation procedure looks straightforward too.
      I don't have a Mac though, so I can't confirm this.
    - The Windows installation procedure looks horrible - I don't know why it's like this.
      If you want to give it a try, [this video](https://www.youtube.com/watch?v=gLr2u6CjSsM) might help.
        - It might be easier to install Ubuntu 20.04 (e.g. in [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10) or in a VM), and then install the `haskell-platform` package as described above.
1. **Download this repository:**
    1. Option A (easiest): **download the zip file** [from here](https://github.com/OsePedro/HaskellIntro/archive/master.zip) and extract its contents.
    1. Option B: **clone the Git repository:**
        1. If you don't already have Git, use [these instructions](https://git-scm.com/downloads) to get it.
        1. Launch a terminal and run

                git clone git@github.com:OsePedro/HaskellIntro.git

1. **Text editor:** You'll need a text editor to edit the code.
If you want syntax highlighting, try one of the following:
    - [Visual Studio Code](https://code.visualstudio.com/) with the [Haskell](https://marketplace.visualstudio.com/items?itemName=haskell.haskell) extension;
    - [Atom](https://atom.io/) with the [language-haskell](https://atom.io/packages/language-haskell) package.
    - If you're a Sublime user, you can try the [SublimeHaskell](https://packagecontrol.io/packages/SublimeHaskell) package.

## Things to Try

1. Load the `Demo` module in `ghci`:
    - If you are running it online, press "Run".
      This will launch `ghci` and load the `Demo` module.
    - If you are running it locally, launch a terminal, navigate to the `HaskellIntro` directory that you downloaded/cloned, and run `ghci`.
      Type `:l Demo` to load `Demo`.
    - `ghci` is a REPL &mdash; an interactive environment in which you can execute arbitrary Haskell expressions.
      It allows us to play around with the messaging system without having to write a user interface.
        - Note that it also gives you direct access to parts of the system that it would be unwise to allow users to directly manipulate.
          E.g. it allows you to put `MsgSys` into invalid states that would not otherwise be reachable through the functions exported by the [MsgSys](MsgSys.hs) module.
    - The loaded `Demo` module gives you access to:
        - Two instances of the type `MsgSys` &mdash; `msgSys0` and `msgSys1`;
        - Three `LoggedInUser`s &mdash; `alerter`, `ose` and `pedro`;
        - All of the functions and types described in the presentation.
1. Type `:t <value/function name>` to view the type of any value or function.
E.g. typing `:t ose` prints:

        ose :: LoggedInUser

    and typing `:t alert` prints:

        alert :: Message -> User -> MsgSys -> MsgSys

1. There are two ways to view values like `msgSys1` and `ose`:
    1. Type its name into `ghci` and press enter.
    This will print a Haskell expression that represents the full state of the value.
    E.g. if you type `ose`, it will print:

            Just (RawCredentials {credsUser = RawUser (StringWrapper "Ose"), credsPassword = StringWrapper "Ose's unguessable password"})

    1. Use the `display` function to print a more readable representation of the value.
    This is especially useful for `MsgSys`, as their Haskell expressions are long and poorly formatted.
    Try executing `display msgSys1` and compare it to what you get when you type `msgSys1` to see what I mean.
        - You can use `display` to view instances of pretty much all types defined in the [MsgSys](MsgSys.hs) module, and lists of these types.
        E.g. if you type `display ose`, it will print:

              User: Ose
              Password: Ose's unguessable password

        - The few types that `display` does not support are simple enough to be viewed as described in the previous point.
1. Open [MsgSys.hs](MsgSys.hs) in a text editor.
You will see a line near the top that says `module MsgSys`.
The list of names in parentheses after that are the values, functions and types that `MsgSys` exports (type names begin with capital letters), which can be used by the [Demo](Demo.hs) module.
    - These types are returned by the exported functions.
    - `display` can print instances of all of these exported types, and lists of these types.
1. Open [Demo.hs](Demo.hs) in a text editor.
1. Add code that `register`s two new `User`s to `msgSys1`.
    - The `initialise` function at the bottom of the file demonstrates how to do this.
    - You can either:
      - modify `initialise`, and the call to `initialise` at the top of the file;
      - or write a new function with type signature `MsgSys -> MsgSys` that takes `msgSys1` and returns the result of registering the two new `User`s.
    - Remember: you can type `:t register` in `ghci` to view `register`'s type signature (or you can just search for the implementation of `register` in [MsgSys.hs](MsgSys.hs)).
1. Reload [Demo.hs](Demo.hs) in `ghci` (i.e. run `:l Demo` again), to make sure it compiles.
    - Feel free to ask me for help if you have any issues.
1. Type `display (allUsers <new MsgSys>)` in `ghci` to check that your new `User`s exist, where `<new MsgSys>` is the result of your new calls to `register`.
1. In [Demo.hs](Demo.hs):
    1. Use the `findUser` function to search for one of these new `User`s by their `Name` (its type signature shows you how to use it) and name the resulting `User` (e.g. `myUser = findUser ...`).
    1. Use the `login` function to log in as the other new `User`, and name the resulting `LoggedInUser`.
    1. Use the `send` function to send a `Message` from your new `LoggedInUser` to your new `User`, and name the resulting `MsgSys`.
        - Note: if you want to `send` a `Message` _to_ a `LoggedInUser`, you have to use the `asUser` function to extract the `User` that it contains.
1. Reload [Demo.hs](Demo.hs) in `ghci` and `display` the new `MsgSys` that you have created.
1. Try out some of the functions that we wrote in the presentation, e.g.: `alertOutOfSpace`, `usedSpace` and `alertMultiOutOfSpace`.
1. Have a go at writing the `sendMulti` function suggested on the [final slide](https://docs.google.com/presentation/d/1bIBQewtYiaXQy0kvyWsJ3YTIPQMGXIq1hXNsOXZcURI/edit#slide=id.g9342e8f7da_2_30).
I'll share the solution later.

## I'm Hooked! Where Can I learn More About Haskell?

- If there's enough demand, I'll happily do another talk in future about some of the things at the bottom of the [Summary](https://docs.google.com/presentation/d/1bIBQewtYiaXQy0kvyWsJ3YTIPQMGXIq1hXNsOXZcURI/edit#slide=id.g964a3bf043_0_14) slide.
    - This will help you to understand more of what's going on in [MsgSys.hs](MsgSys.hs).
- [A Gentle Introduction to Haskell](https://www.haskell.org/tutorial/) &mdash; a short and sweet tutorial.
- [Learn You a Haskell for Great Good](http://learnyouahaskell.com/) &mdash; I've barely read any of this, but what I've seen so far seems good, and it's free to read online.

## Big Cash Prize! 🤑💰

I created [this image](images/chicks.svg) for the presentation, then changed my mind about using it.
But I like it so much that I thought it would be a shame not to share it with the world.
I'll send £10 to the first person who correctly guesses how I was going to relate it to the presentation.
