module ToolipsManager
using Toolips
using ToolipsRemote

function ManagementServer(ip::String, port::Int64, hostname::String;
routes::Vector{<: Toolips.AbstractRoute} = Vector{Toolips.AbstractRoute}(),
extensions::Vector{<: Toolips.ServerExtension} = Vector{Toolips.ServerExtension}()
    )
    push!(extensions, ManagerRemote())
    WebServer(ip, port, hostname = hostname, routes = routes,
    extensions = extensions)
end


end # module
