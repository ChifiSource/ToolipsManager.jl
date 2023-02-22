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
using ToolipsSession

"""
**Manager**
### manager_help(args::Vector{String}, c::RemoteConnection)
------------------
This is a controller function that provides the `?` application functionality
to the `Remote` extension returned by both `manager_remote` and
`management_server_remote`. If you want to deploy a server which manages other
ToolipsServers (it can still be a website or endpoint server, it just also
features other servers in a Vector within.) This way server controls can be
external rather than internal with a mere use of `add_remote`.
#### example
```

```
"""
function manager_help(args::Vector{String}, c::RemoteConnection)
    return("""## ToolipsManager""")
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
    key = ToolipsSession.gen_ref()
    r = route("/manage") do c::Connection
        g = getargs(c)
        if :key in keys(g)
            if g[:key] == key
                write!(c, "hello!")
            end
        end
    end
    push!(c.routes, r)
    link = "http://127.0.0.1:8001/manage?key=$key"
    return("""[overiew]($link)""")
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
    remotefunctions = ToolipsRemote.controller(universal_controls)
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
    d = Dict{Int64, Function}()
    push!(d, 5 => ToolipsRemote.controller(contr))
    users = [name => key => 5]
    Remote(d, users; motd = motd)
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
    host::String
    port::Int64
    routes::Vector{AbstractRoute}
    server::Toolips.Sockets.TCPServer
    extensions::Vector{ServerExtension}
    servers::Vector{Toolips.WebServer}
    start::Function
    function ManagementServer(servers::Vector{WebServer},
        usrpwd::Pair{String, String},
        ip::String = "127.0.0.1", port::Int64 = 8000;
        host::String = "", routes::Vector{AbstractRoute} = routes(route("/",
        (c::Connection) -> write!(c, p(text = "Hello world!")))),
        extensions::Vector{ServerExtension} = Vector{ServerExtension}([]))
        server::Sockets.TCPServer = Sockets.listen(Sockets.InetAddr(
        parse(IPAddr, ip), port))
        push!(extensions, management_server_remote(usrpwd[1], usrpwd[2], "hello"))
        start() = Toolips._start(ip, port, routes, extensions, server, host)
        new(ip, host, port, routes, server,  extensions, servers, start)::ManagementServer
    end
end

export add_management!, ManagementServer


end # module
