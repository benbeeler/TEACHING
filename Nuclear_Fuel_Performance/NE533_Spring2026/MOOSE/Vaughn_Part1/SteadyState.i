[Mesh]
#Mesh generation generates each block with subdivisions, stitches together with stitched mesh
#generator then uses subdomain generator to rename blocks with 1=fuel 2=gap 3=clad
 [right]
  type = GeneratedMeshGenerator
  dim = 2
  xmin = 0
  xmax = 0.5
  ymin = 0.0
  ymax = 0.1
  nx = 34
  ny = 3
 []
 [middle]
  type = GeneratedMeshGenerator
  dim = 2
  xmin = 0.5
  xmax = 0.505
  ymin = 0.0
  ymax = 0.1
  nx = 34
  ny = 3
 []
 [left]
  type = GeneratedMeshGenerator
  dim = 2
  xmin = 0.505
  xmax = 0.605
  ymin = 0.0
  ymax = 0.1
  nx = 34
  ny = 3
 []
 [cmbn]
  type = StitchedMeshGenerator
  inputs = 'right middle left'
  show_info = True
  stitch_boundaries_pairs = 'right left;
  right left; right left'
 []
 [fuel] 
   type = SubdomainBoundingBoxGenerator
   input = cmbn
   block_id = 1
   bottom_left = '0.0 0.0 0.0'
   top_right = '0.5 0.1 0.0'
 []
 [gap]
   type = SubdomainBoundingBoxGenerator
   input = fuel
   block_id = 2
   bottom_left = '0.5 0.0 0.0'
   top_right = '0.505 0.1 0.0'
 []
 [clad] 
   type = SubdomainBoundingBoxGenerator
   input = gap 
   block_id = 3
   bottom_left = '0.505 0.0 0.0'
   top_right = '0.605 0.1 0.0'
 []
 coord_type = 'RZ'
[]
#Define materials
[Materials]
[./fuel]
type = HeatConductionMaterial
block = 1
thermal_conductivity = .03
[../]
[./gap]
type = HeatConductionMaterial
block = 2
thermal_conductivity = 0.004
[../]
[./clad]
type = HeatConductionMaterial
block = 3
thermal_conductivity = .18
[../]
[]
#Define Variables
[Variables]
        [./temp]
                order = FIRST
                family = LAGRANGE        
        [../]
[]
#Define Kernels
[Kernels]
        #add in kernels here
        [./heat_conduction]
                type = HeatConduction
                variable = temp
        [../]
        [./heat_source]
                type = HeatSource
                variable = temp
                block = 1
                value = 445.63384
        [../]
[]

#Define BCs
[BCs]
        [./fixed_temp]
                type = DirichletBC
                variable = temp
                boundary = right
                value = 550
        [../]
        [./centerline_flux]
                type = NeumannBC
                variable = temp
                boundary = left
                value = 0
        [../]
        #add in boundary conditions here
[]


#Choose executioner and parameters
[Executioner]
  type = Steady
  solve_type = 'PJFNK'
[]
#Outputs
[Outputs]
        #[./mesh_before_solve]
        #        type = Exodus
        #        file_base = refined_mesh
        #        execute_on = INITIAL
        #[../]
        execute_on = 'timestep_end'
        exodus = true
[]

