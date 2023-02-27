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
# using ToolipsSession
using Toolips.Dates

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
add_management!(ws::ToolipsServer,  namekey::Pair{String, String},
    servers::Vector{WebServer} = Vector{WebServer}();
    motd::String = """##### please login:""") = begin
    [begin
        push!(serve.extensions, ManagerProbe())
        serve.start()
    end for serve in servers]
    push!(ws.extensions, manager_remote(namekey[1], namekey[2], motd))
    push!(ws.extensions, Manager(servers))
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
    universal_controls = Dict{String, Function}(
        "?" => manager_help, "status" => status,
        "manage" => management, "check" => check, "overview" => overview)
    d = Dict{Int64, Function}(5 => ToolipsRemote.controller(universal_controls))
    users = [name => key => 5]
    Remote(d, users; motd = motd)
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

    push!(d, )
    users = [name => key => 5]
    Remote(d, users; motd = motd)
end

mutable struct Manager <: Toolips.ServerExtension
    type::Symbol
    servers::Vector{WebServer}
    function Manager(servers::Vector{WebServer})
        new(:connection, servers)::Manager
    end
end

mutable struct ManagerProbe <: Toolips.ServerExtension
    type::Symbol
    data::Dict{Date, Dict{Symbol, Any}}
    f::Function
    function ManagerProbe()
        data = Dict{Date, Dict{Symbol, Any}}()
        f(c::Toolips.AbstractConnection) = begin
            td::Date = today()
            if td in keys(data)
                data[td][:visits] += 1
                return
            end
            push!(data, td => Dict{Symbol, Any}(:visits => 1))
        end
        new(:func, data, f)
    end
end

export add_management!


end # module
