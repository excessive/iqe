# Inter-Quake Export Loader

Inter-Quake Export Loader is a library for parsing Inter-Quake Export files into Lua data structures.

Buffering models is supported using the [**LÖVE**][LOVE] game framework.

## Quick Example

```lua
local iqe   = require "iqe"
local model = iqe.load("foo.iqe")
```

## License

This code is licensed under the [**MIT Open Source License**][MIT]. Check out the LICENSE file for more information.

[LOVE]: https://www.love2d.org/
[MIT]: http://www.opensource.org/licenses/mit-license.html
