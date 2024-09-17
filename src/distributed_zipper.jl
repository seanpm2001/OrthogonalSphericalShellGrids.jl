using Oceananigans.BoundaryConditions: fill_open_boundary_regions!, 
                                       permute_boundary_conditions, 
                                       fill_halo_event!,
                                       DistributedCommunication

using Oceananigans.DistributedComputations: cooperative_waitall!,
                                            recv_from_buffers!,
                                            fill_corners!,
                                            loc_id, 
                                            DCBCT

import Oceananigans.BoundaryConditions: fill_halo_regions!
import Oceananigans.DistributedComputations: synchronize_communication!

@inline instantiate(T::DataType) = T()
@inline instantiate(T) = T

const DistributedZipper = BoundaryCondition{<:DistributedCommunication, <:ZipperHaloCommunicationRanks}

switch_north_halos!(c, north_bc, grid, loc) = nothing

function switch_north_halos!(c, north_bc::DistributedZipper, grid, loc) 
    sign  = north_bc.condition.sign
    hz = halo_size(grid)
    sz = size(parent(c))
    gs = size(grid)

    _switch_north_halos!(parent(c), loc, sign, sz, gs, hz)

    return nothing
end



# We throw away the first point!
@inline function _switch_north_halos!(c, ::Tuple{<:Center, <:Center, <:Any}, sign, sz, (Nx, Ny, Nz), (Hx, Hy, Hz)) 
    
    # Find the correct domain indices
    north_halos  = Ny+Hy+1:Ny+2Hy-1
    reversed_north_halos = Ny+2Hy:-1:Ny+Hy+2
    west_corner = 1:Hx
    east_corner = Nx+Hx+1:Nx+2Hx
    interior    = Hx+1:Nx+Hx

    view(c, west_corner, north_halos, :) .= sign .* reverse(view(c, west_corner, reversed_north_halos, :), dims = 1) 
    view(c, east_corner, north_halos, :) .= sign .* reverse(view(c, east_corner, reversed_north_halos, :), dims = 1) 
    view(c, interior,    north_halos, :) .= sign .* reverse(view(c, interior,    reversed_north_halos, :), dims = 1) 

    return nothing
end

# We do not throw away the first point!
@inline function _switch_north_halos!(c, ::Tuple{<:Center, <:Face, <:Any}, sign, sz, (Nx, Ny, Nz), (Hx, Hy, Hz))  
    north_halos  = Ny+Hy+1:Ny+2Hy
    reversed_north_halos = Ny+2Hy:-1:Ny+Hy+1
    west_corner = 1:Hx
    east_corner = Nx+Hx+1:Nx+2Hx
    interior    = Hx+1:Nx+Hx

    view(c, west_corner, north_halos, :) .= sign .* reverse(view(c, west_corner, reversed_north_halos, :), dims = 1) 
    view(c, east_corner, north_halos, :) .= sign .* reverse(view(c, east_corner, reversed_north_halos, :), dims = 1) 
    view(c, interior,    north_halos, :) .= sign .* reverse(view(c, interior,    reversed_north_halos, :), dims = 1) 

    return nothing
end

# We throw away the first line and the first point!
@inline function _switch_north_halos!(c, ::Tuple{<:Face, <:Center, <:Any}, sign, (Px, Py, Pz), (Nx, Ny, Nz), (Hx, Hy, Hz)) 
    north_halos  = Ny+Hy+1:Ny+2Hy-1
    reversed_north_halos = Ny+2Hy:-1:Ny+Hy+2
    west_corner = 2:Hx
    east_corner = Nx+Hx+1:Nx+2Hx
    interior    = Hx+1:Nx+Hx

    view(c, west_corner, north_halos, :) .= sign .* reverse(view(c, west_corner, reversed_north_halos, :), dims = 1) 
    view(c, east_corner, north_halos, :) .= sign .* reverse(view(c, east_corner, reversed_north_halos, :), dims = 1) 
    view(c, interior,    north_halos, :) .= sign .* reverse(view(c, interior,    reversed_north_halos, :), dims = 1) 

    return nothing
end

# We throw away the first line but not the first point!
@inline function _switch_north_halos!(c, ::Tuple{<:Face, <:Face, <:Any}, sign, (Px, Py, Pz), (Nx, Ny, Nz), (Hx, Hy, Hz)) 
    north_halos  = Ny+Hy+1:Ny+2Hy
    reversed_north_halos = Ny+2Hy:-1:Ny+Hy+1
    west_corner = 2:Hx
    east_corner = Nx+Hx+1:Nx+2Hx
    interior    = Hx+1:Nx+Hx

    view(c, west_corner, north_halos, :) .= sign .* reverse(view(c, west_corner, reversed_north_halos, :), dims = 1) 
    view(c, east_corner, north_halos, :) .= sign .* reverse(view(c, east_corner, reversed_north_halos, :), dims = 1) 
    view(c, interior,    north_halos, :) .= sign .* reverse(view(c, interior,    reversed_north_halos, :), dims = 1) 

    return nothing
end

function fill_halo_regions!(c::OffsetArray, bcs, indices, loc, grid::DTRG, buffers, args...; only_local_halos = false, fill_boundary_normal_velocities = true, kwargs...)
    if fill_boundary_normal_velocities
        fill_open_boundary_regions!(c, bcs, indices, loc, grid, args...; kwargs...)
    end
    
    north_bc = bcs.north

    arch = architecture(grid)
    fill_halos!, bcs = permute_boundary_conditions(bcs) 

    number_of_tasks = length(fill_halos!)

    for task = 1:number_of_tasks
        fill_halo_event!(c, fill_halos![task], bcs[task], indices, loc, arch, grid, buffers, args...; only_local_halos, kwargs...)
    end

    fill_corners!(c, arch.connectivity, indices, loc, arch, grid, buffers, args...; only_local_halos, kwargs...)
    
    # We increment the tag counter only if we have actually initiated the MPI communication.
    # This is the case only if at least one of the boundary conditions is a distributed communication 
    # boundary condition (DCBCT) _and_ the `only_local_halos` keyword argument is false.
    increment_tag = any(isa.(bcs, DCBCT)) && !only_local_halos
    
    if increment_tag 
        arch.mpi_tag[] += 1
    end
        
    switch_north_halos!(c, north_bc, grid, loc)
    
    return nothing
end

function synchronize_communication!(field::Field{<:Any, <:Any, <:Any, <:Any, <:DTRG})
    arch = architecture(field.grid)

    # Wait for outstanding requests
    if !isempty(arch.mpi_requests) 
        cooperative_waitall!(arch.mpi_requests)

        # Reset MPI tag
        arch.mpi_tag[] = 0

        # Reset MPI requests
        empty!(arch.mpi_requests)
    end

    recv_from_buffers!(field.data, field.boundary_buffers, field.grid)

    north_bc = field.boundary_conditions.north
    instantiated_location = map(instantiate, location(field))

    switch_north_halos!(field, north_bc, field.grid, instantiated_location)

    return nothing
end