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
using Toolips.Dates
using Prrty
using ToolipsDefaults

"""
### ? (command::String)
The ? command is used to get helpful information on different controller commands.
Use `? (method)` to learn more about each command. **Bold** arguments are
required.\n
| command | args |
|:---------- | ---------- |
| ?   | (method::String)  |
| list   |                |
| kill   | (**server**::Int64) |
| overview |    |
"""
function manager_help(args::Vector{String}, c::RemoteConnection)
    helpinfo = Dict("?" => @doc(manager_help), "overview" => @doc(overview),
    "list" => @doc(list), "kill" => @doc(kill))
    if length(args) == 0
        write!(c, string(helpinfo["?"]))
    elseif length(args) == 1
        println(args[1])
        if args[1] in keys(helpinfo)
            write!(c, string(helpinfo[args[1]]))
            return
        end
        write!(c, "the method you requested help for does not exist.")
    end

end

"""
**Manager**
### overview(args::Vector{String}, c::RemoteConnection)
------------------

#### example
```

```
"""
function overview(args::Vector{String}, rc::RemoteConnection)
    key = ToolipsSession.gen_ref()
    r = route("/manage") do c::Connection
        g = getargs(c)
        if :key in keys(g)
            if g[:key] == key
                mainwindow = div("managerwindow")
                mainwindow[:children] = Vector{Servable}([begin
                mainsection = section("server-$e")
                portheading = h("portheading$e", 2, text = string(server.port))
                hname = h("hheading$e", 3, text = server.hostname)
                datedata = server[:ManagerProbe].data
                d = Dict([d => datedata[d][:visits] for d in keys(datedata)])
                lplot = Prrty.line(Vector{Date}(collect(keys(d))),
                 Vector{Int64}(collect(values(d))))
                killbutton = button("killbutton$e", text = "kill")
                if server.server.status != 4
                    killbutton[:text] = "start"
                end
                on(c, killbutton, "click") do cm::ComponentModifier
                    if server.server.status == 4
                        kill!(server)
                        set_text!(cm, killbutton, "start")
                    else
                        server.start()
                        set_text!(cm, killbutton, "kill")
                    end
                end
                push!(mainsection, portheading, hname, killbutton, br(),
                lplot.window)
                mainsection::Component{:section}
            end for (e, server) in enumerate(c[:Manager].servers)])
                write!(c, mainwindow)
            end
        end
    end
    push!(rc.routes, r)
    link = "http://127.0.0.1:8000/manage?key=$key"
    return("""[overview]($link)""")
end

function list(args::Vector{String}, c::RemoteConnection)
    [begin
        active = "inactive\n"
        if server.server.status == 4
            active = "active\n"
        end
        write!(c, h("myh", 3, text = "[$e] $(server.hostname): $(server.port)"))
        write!(c, p("active", text = active))
    end for (e, server) in enumerate(c[:Manager].servers)]
end

function kill(args::Vector{String}, c::RemoteConnection)
    if length(args) == 1
        try
            n = parse(Int64, args[1])
            serve = c[:Manager].servers[n]
            kill!(serve)
            write!(c, "server $n was stopped ($(serve.hostname):$(serve.port))")
        catch
            write!(c, "something went wrong ...")
        end
        return
    end
    write!(c, p("imp",
    text = "improper usage, please provide a server index, for example:\n"))
    write!(c, """```
    kill 1
    ```""")
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
        "?" => manager_help, "list" => list,
        "overview" => overview, "kill" => kill)
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
