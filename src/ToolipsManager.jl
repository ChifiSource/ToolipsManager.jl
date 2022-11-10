module ToolipsManager
using Toolips
import Toolips: ServerExtension, ToolipsServer
using ToolipsRemote
using ToolipsAuth

add_management(ws::WebServer, key::String;
    motd = """##### please login:""") = begin
    push!(ws, manager_remote(ws.hostname, key, motd))
end

function manager_remote(name::String, key::String, motd::String)
    remotefunctions = Dict(5 => manager_controller())
    users = [name => key => 5]
    Remote(remotefunction, users; motd = motd)
end

function manager_controller(controls::Dict{String, Function} = Dict(
    "?" => manager_help, "overview" => overview,
    "manage internals" => manage_internals))
end

function manager_help(args::Vector{String}, c::RemoteConnection)

end

function overview()

end

function manage_internals()

end

mutable struct ManagementServer <: ToolipsServer
    ip::String
    hostname::String
    port::Int64
    routes::Vector{AbstractRoute}
    extensions::Vector{ServerExtension}
    servers::Vector{ToolipsServer}
    function ManagementServer()

    end
end
end # module
