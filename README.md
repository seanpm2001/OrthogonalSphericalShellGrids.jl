# OrthogonalSphericalShellGrids

Tools for constructing [`Oceananigans`](https://github.com/CliMA/Oceananigans.jl) grids that represent orthogonal meshes of thin spherical shells, which prove particularly useful for ocean simulations.

[![Build Status](https://github.com/simone-silvestri/OrthogonalSphericalShellGrids.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/simone-silvestri/OrthogonalSphericalShellGrids.jl/actions/workflows/CI.yml?query=branch%3Amain)

<a href="https://mit-license.org">
    <img alt="MIT license" src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square">
</a>
<a href="https://clima.github.io/OrthogonalSphericalShellGrids.jl/dev">
    <img alt="Documentation" src="https://img.shields.io/badge/documentation-stable%20release-red?style=flat-square">
</a>

Running `examples/generate_grid.jl` visualizes the `TripolarGrid` ([generated by a series of cofocal ellipses perpendicular to a family of hyperbolae]((https://www.sciencedirect.com/science/article/abs/pii/S0021999196901369))),
producing

<img width="571" alt="Screen Shot 2024-05-14 at 10 45 13 PM" src="https://github.com/simone-silvestri/OrthogonalSphericalShellGrids.jl/assets/33547697/a22d3b87-1172-4309-a26f-e0824b5a2c1a">
