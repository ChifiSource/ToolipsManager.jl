module ToolipsManager
using Toolips
import Toolips: ServerExtension, ToolipsServer
using ToolipsRemote
using ToolipsSession

add_management!(ws::ToolipsServer, key::String;
    motd::String = """##### please login:""") = begin
    push!(ws, manager_remote(ws.hostname, key, motd))
end

universal_controls = Dict{String, Function}(
    "?" => manager_help, "status" => status,
    "manage" => management, "check" => check)

function manager_remote(name::String, key::String, motd::String)
    remotefunctions = Dict(5 => ToolipsRemote.controller(universal_controls))
    users = [name => key => 5]
    Remote(remotefunction, users; motd = motd)
end

function management_server_remote(name::String, key::String, motd::String)
    contr = copy(universal_controls)
    push!(contr, "overview" => overview)
    ToolipsRemote.controller()
    remotefunctions = Dict(5 => )
    users = [name => key => 5]
    Remote(remotefunction, users; motd = motd)
end

function manager_help(args::Vector{String}, c::RemoteConnection)

end

function overview(args::Vector{String}, c::RemoteConnection)

end

function status(args::Vector{String}, c::remoteConnection)

end

function check(args::Vector{String}, c::RemoteConnection)

end

function management(args::Vector{String}, c::RemoteConnection)

end

function manage(c::Connection)

end



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
        extensions::Vector{ServerExtension})
        push!(extensions, management_server_remote(hostname))
        start() = Toolips._start(host, port, routes, extensions, server, hostname)
        new(host, hostname, port, routes, extensions, servers, start)::ManagementServer
    end
end



end # module
