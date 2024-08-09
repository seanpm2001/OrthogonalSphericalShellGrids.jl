<!-- Title -->
<h1 align="center">
  OrthogonalSphericalShellGrids.jl
</h1>

<!-- description -->
<p align="center">
  <strong>🌐 Recipes and tools for Tools for constructing  <a href="https://github.com/CliMA/Oceananigans.jl">Oceananigans</a> grids that represent orthogonal meshes of thin spherical shells, which prove particularly useful for ocean simulations.</strong>
</p>

<!-- Information badges -->
<p align="center">
    <a href="https://mit-license.org">
        <img alt="MIT license" src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square">
    </a>
    <a href="https://clima.github.io/OrthogonalSphericalShellGrids.jl/dev">
        <img alt="Documentation" src="https://img.shields.io/badge/documentation-stable%20release-red?style=flat-square">
    </a>
    <a href="https://github.com/CliMA/OrthogonalSphericalShellGrids.jl/actions/workflows/CI.yml?query=branch%3Amain">
        <img alt="Build status" src="https://github.com/simone-silvestri/OrthogonalSphericalShellGrids.jl/actions/workflows/CI.yml/badge.svg?branch=main">
    </a>
</p>

Running `examples/generate_grid.jl` visualizes the `TripolarGrid` ([generated by a series of cofocal ellipses perpendicular to a family of hyperbolae]((https://www.sciencedirect.com/science/article/abs/pii/S0021999196901369))),
producing

<p align="center">
<img width="571" alt="Screen Shot 2024-05-14 at 10 45 13 PM" src="https://github.com/simone-silvestri/OrthogonalSphericalShellGrids.jl/assets/33547697/a22d3b87-1172-4309-a26f-e0824b5a2c1a">
</p>
