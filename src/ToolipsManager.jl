"""
Created in February, 2022 by
[chifi - an open source software dynasty.](https://github.com/orgs/ChifiSource)
by team
[toolips](https://github.com/orgs/ChifiSource/teams/toolips)
This software is MIT-licensed.
### ToolipsManager
ToolipsManager provides an easy way to manage and modularize several
toolips projects in one session. Servers become introspectable objects through
a remote client which can be served to alter and work with server information
either by loadding a specific remote controller by using `add_management!`, or
creating `manager_remote(name::String, key::String, motd::String)`. There is the
other option of managing other toolips servers using the `ManagementServer`, which
is a toolips server.
##### Module Composition
- [**ToolipsManager**](https://github.com/ChifiSource/Toolips.jl)
"""
module ToolipsManager
using Toolips
import Toolips: ServerExtension, ToolipsServer, AbstractRoute
using ToolipsRemote
using ToolipsRemote: RemoteConnection

"""
**Manager**
### manager_help(args::Vector{String}, c::RemoteConnection)
------------------

#### example
```

```
"""
function manager_help(args::Vector{String}, c::RemoteConnection)
    write!(c, h("e", 2, text = "help"))
end

"""
**Manager**
### overview(args::Vector{String}, c::RemoteConnection)
------------------

#### example
```

```
"""
function overview(args::Vector{String}, c::RemoteConnection)

end

"""
**Manager**
### status(args::Vector{String}, c::RemoteConnection)
------------------

#### example
```

```
"""
function status(args::Vector{String}, c::RemoteConnection)
    write!(c, h("e", 2, text = "$(c.hostname) status"))
    stats = """$([r.path * "\n" for r in c.routes])
        $([typeof(ext) * "\n" for ext in c.extensions])
    """
end

"""
**Manager**
### check(args::Vector{String}, c::RemoteConnection)
------------------

#### example
```

```
"""
function check(args::Vector{String}, c::RemoteConnection)

end

"""
**Manager**
### management(args::Vector{String}, c::RemoteConnection)
------------------

#### example
```

```
"""
function management(args::Vector{String}, c::RemoteConnection)

end

"""
**Manager**
### manage(c::Connection)
------------------

#### example
```

```
"""
function manage(c::Connection)

end

universal_controls = Dict{String, Function}(
    "?" => manager_help, "status" => status,
    "manage" => management, "check" => check)

"""
**Manager**
### add_management!(ws::ToolipsServer, key::String; motd::String = "##### please login")
------------------
Adds Manager's remote extension to a server, putting the `manager_remote` controller
to return the `ToolipsRemote` extension.
#### example
```

```
"""
add_management!(ws::ToolipsServer, key::String;
    motd::String = """##### please login:""") = begin
    push!(ws, manager_remote(ws.hostname, key, motd))
end

"""
**Manager**
### manager_remote(name::String, key::String, motd::String) -> ::ToolipsRemote.Remote
------------------
Createss a remote function by plugging universal controls into the `ToolipsRemote.controller`
    and using that controller to construct a new `ToollpsRemote.Remote` extension.
#### example
```

```
"""
function manager_remote(name::String, key::String, motd::String)
    remotefunctions = Dict(5 => ToolipsRemote.controller(universal_controls))
    users = [name => key => 5]
    Remote(remotefunctions, users; motd = motd)
end

"""
**Manager**
### management_server_remote(name::String, key::String, motd::String) -> ::ToolipsRemote.Remote
------------------
Createss a remote function by plugging universal controls into the `ToolipsRemote.controller`
    and using that controller to construct a new `ToollpsRemote.Remote` extension.
#### example
```

```
"""
function management_server_remote(name::String, key::String, motd::String)
    contr = copy(universal_controls)
    push!(contr, "overview" => overview)
    ToolipsRemote.controller()
    remotefunctions = Dict(5 => ToolipsRemote.controller(universal_controls))
    users = [name => key => 5]
    Remote(remotefunctions, users; motd = motd)
end

"""
### ManagementServer <: ToolipsServer
- ip**::String**
- hostname**::String**
- port**::Int64**
- routes**::Vector{AbstractRoute}**
- extensions**::Vector{ServerExtension}**
- servers**::Vector{Toolips.WebServer}**
- start**::Function**

The Toolips `ManagementServer`
##### example
```

```
------------------
##### constructors
- ManagementServer(servers::Vector{Toolips.WebServer}, usrpwd::Pair{String, String},
host::String = "127.0.0.1", port::Int64 = 8000; hostname::String = "",
routes::Vector{AbstractRoute} = [route("/", ...)], extensions::Vector{ServerExtension})
"""
mutable struct ManagementServer <: ToolipsServer
    ip::String
    hostname::String
    port::Int64
    routes::Vector{AbstractRoute}
    extensions::Vector{ServerExtension}
    servers::Vector{Toolips.WebServer}
    start::Function
    function ManagementServer(servers::Vector{Toolips.WebServer},
        usrpwd::Pair{String, String},
        host::String = "127.0.0.1", port::Int64 = 8000;
        hostname::String = "", routes::Vector{AbstractRoute} = routes(route("/",
        (c::Connection) -> write!(c, p(text = "Hello world!")))),
        extensions::Vector{ServerExtension} = Vector{ServerExtension}([]))
        push!(extensions, management_server_remote(usrpwd[1], usrpwd[2], "hello"))
        start() = Toolips._start(host, port, routes, extensions, server, hostname)
        new(host, hostname, port, routes, extensions, servers, start)::ManagementServer
    end
end

export add_management!, ManagementServer


end # module
