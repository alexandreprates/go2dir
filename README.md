# GO2DIR

[![Build Status](https://travis-ci.org/alexandreprates/go2dir.svg?branch=dev)](https://travis-ci.org/alexandreprates/go2dir)

A simple way to go to your favorites directories

![How to Use](https://github.com/alexandreprates/go2dir/blob/dev/examples/how_to_use.gif?raw=true)

## How to install

Install base script

```bash
$ curl https://raw.githubusercontent.com/alexandreprates/go2dir/master/install | bash
```

## How to use

Add directory to go2 list:

```bash
$ go2 -a <path> [<name>]
```

Map development to /home/someuser/workspace/development

```bash
$ cd /home/someuser/workspace/development
$ go2 -a .
Mapping development to /home/someuser/workspace/development
```

Map dev to /home/someuser/workspace/development

```bash
$ cd /home/someuser/workspace/development
$ go2 -a . dev
Mapping dev to /home/someuser/workspace/development
```

Go to dir from anywhere with:

```bash
$ go2 development
go to development at /home/someuser/workspace/development

$ go2 dev
go to dev at /home/someuser/workspace/development
```

Spaces in the directory name will be replaced by a dash

```bash
$ cd /home/someuser/workspace/some\ dir\ with\ spaces
$ go2 -a .
Mapping some-dir-with-spaces to /home/someuser/workspace/some dir with spaces
```

Go to dir from anywhere with:
```bash
$ go2 some-dir-with-spaces
go some-dir-with-spaces at /home/someuser/workspace/some dir with spaces
```

List maped directories:
```bash
$ go2 -l
Maped dirs in /home/someuser/.local/share/go2dir/locations.txt

  development|/home/someuser/workspace/development
  dev|/home/someuser/workspace/development
  some-dir-with-spaces|/home/someuser/workspace/some dir with spaces

```

Removed maped directories:
```bash
$ go2 -R development
development was successfully removed
```

## License (MIT license)

The MIT License (MIT)

Copyright (c) 2014 Alexandre Prates

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

