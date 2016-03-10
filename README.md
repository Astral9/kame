
# Kame

## What is Kame?
* `Kame` is a makefile-like tool written in Ruby.

## Why Kame?
* `Kamefile` (as supposed to `Makefile`) is written in Ruby and therefore more 
friendly to Ruby programmers compared to its counterpart. No to mention the
awesome libraries that are made available to make your life easier.

## What stage is it on?
* Very early stage. `Kame` still needs:
  * documentation
  * tests
  * multi-thread support (structure already built)
  * a friendly installation process
  * get rid of the `TODO` tags left

## Installation
`Kame` has no installation helper at this moment, but as it does not require
any dependency (other than Ruby itself) the setup is fairly straight forward:

1. clone this repo.
2. in your shell (or shell profile files), set the alias
  ```
  alias kame = ruby -I /path/to/the/repo/lib /path/to/the/repo/lib/kame.rb
  ```

and that's it! Try `kame --help` and see if it works.

## `Kamefile` Usage
There are some usage examples in `examples/`. The documentation will come later
if `Kame` is proven to be useful.
