## Units: cm-s-k
[Problem]
        coord_type = RZ
[]

[GlobalParams]
        displacements = 'disp_x disp_y'
[]
[Mesh]
        [cladding]
             type = GeneratedMeshGenerator
             dim = 2
             nx = 30
             ny = 30
             xmin = 0.502
             xmax = 0.602
             ymin = 0
             ymax = 1.0
             boundary_name_prefix = clad
        []
        [clad_block]
                type = SubdomainIDGenerator
                input = cladding
                subdomain_id = 1
        []
        [gap]
                type = GeneratedMeshGenerator
                dim = 2
                nx = 10
                ny = 30
                xmin = 0.5
                xmax = 0.502
                ymin = 0
                ymax = 1.0
                boundary_name_prefix = gap
                boundary_id_offset = 4
        []
        [gap_block]
                type = SubdomainIDGenerator
                input = gap
                subdomain_id = 2
        []
        [fuel]
                type = GeneratedMeshGenerator
                dim = 2
                nx = 120
                ny = 30
               # xmin = 0.102
                xmax = 0.5  # 0.602
                ymin = 0
                ymax = 1.0
                boundary_name_prefix = fuel
                boundary_id_offset = 8
        []
        [fuel_block]
                type = SubdomainIDGenerator
                input = fuel
                subdomain_id = 3
        []
        [system_mesh]
                type = StitchedMeshGenerator #MeshCollectionGenerator
                inputs = 'clad_block gap_block fuel_block'
                stitch_boundaries_pairs = 'clad_left gap_right;
                                           gap_left fuel_right'
        []
        [block_rename]
                type = RenameBlockGenerator
                input = system_mesh
                old_block = '1 2 3'
                new_block = 'clad_block gap_block fuel_block'
        []
[]

[Variables]
        [temperature]
        []
[]

[Kernels]
        [clad_conduction]
                type = HeatConduction
                variable = temperature
                block = 'clad_block'
        []
        [gap_conduction]
                type = HeatConduction
                variable = temperature
                block = 'gap_block'
        []
        [fuel_conduction]
                type = HeatConduction
                variable = temperature
                block = 'fuel_block'
        []
        [q]
                type = HeatSource
                function = 300/(pi*0.5^2) #metric heat rate calculated from linear-heat-rate
                variable = temperature
                block = 'fuel_block'#assume heat source is from the fuel only
        []
[]

[Modules/TensorMechanics/Master]
        [fuel]
                add_variables = true
                strain = small #FINITE
                automatic_eigenstrain_names = true
                generate_output = 'vonmises_stress stress_xx strain_xx stress_yy strain_yy'
                temperature = temperature
        []
[]

[BCs]
        [clad_left]
                type = DirichletBC
                variable = temperature
                value = 600
                boundary = 'clad_right'
        []
        [fuel_right]
                type = NeumannBC
                variable = temperature
                boundary = 'fuel_left'
                value = 0 #adiabatic 
        []
        [center_axis_fix]
                type = DirichletBC
                variable = disp_x
                boundary = 'fuel_left'
                value = 0
        []
        [y_translation_fix]
                type = DirichletBC
                variable = disp_y
                boundary = 'fuel_bottom fuel_top'
                value = 0
        []
        [y_translation_fix_gap]
                type = DirichletBC
                variable = disp_y
                boundary = 'gap_bottom gap_top'
                value = 0
        []
        [y_translation_fix_clad]
                type = DirichletBC
                variable = disp_y
                boundary = 'clad_bottom clad_top'
                value = 0
        []
[]

[Materials]
        [cladding_TC]
                type = HeatConductionMaterial
                thermal_conductivity = 0.15
                block = 'clad_block'
        []
        [gap_TC]
                type = HeatConductionMaterial
                thermal_conductivity = 0.0026 #helium
                block = 'gap_block'
        []
        [fuel_TC]
                type = HeatConductionMaterial
                thermal_conductivity = 0.03 #constant thermal conductivity
               #for non-constant thermal conductivity: thermal_conductivity_temperature_function = (100/(7.5408+17.629*(T/1000)+3.6142*(temperature/1000)^2))+(6400/(temperature/1000)^(5/2))*exp(-16.35*(temperature/1000)) #correlation from in-class for UO2
                block = 'fuel_block'
        []
        [fuel_elasticity]
                type = ComputeIsotropicElasticityTensor
                youngs_modulus = 2e11
                poissons_ratio = 0.345
                block = 'fuel_block'
        []
       [gap_elasticity]
                type = ComputeIsotropicElasticityTensor
               compute = False
                youngs_modulus = 1e6 #any number since it wont be computed
                poissons_ratio = 0.3 #any number since it wont be computed
                block = 'gap_block'
        []
        [clad_elasticity]
                type = ComputeIsotropicElasticityTensor
                youngs_modulus = 8e10
                poissons_ratio = 0.41
                block = 'clad_block'
        []
        [eigen_strain_fuel]
                type = ComputeThermalExpansionEigenstrain
                eigenstrain_name = thermal_expansion
                temperature = temperature
                thermal_expansion_coeff = 11e-6        
                stress_free_temperature = 300
                block = 'fuel_block'
       []
        [eigen_strain_gap]
                type = ComputeThermalExpansionEigenstrain
               compute = False
                eigenstrain_name = thermal_expansion
                temperature = temperature
                thermal_expansion_coeff = 0 #any number
                stress_free_temperature = 300
               block = 'gap_block'
        []
        [eigen_strain_clad]
             type = ComputeThermalExpansionEigenstrain
                eigenstrain_name = thermal_expansion
                temperature = temperature
                thermal_expansion_coeff = 7.1e-6
                stress_free_temperature = 300
                block = 'clad_block'
      []
        [stress]
                type = ComputeStrainIncrementBasedStress
        []
        
[]

[Preconditioning]
        [smp]
                type = SMP
                full = true
        []
[]
                
[Executioner]
        type = Steady
       solve_type = 'PJFNK'
      petsc_options_iname = '-pc_type'
        petsc_options_value = 'lu'

[]

[Outputs]
        execute_on = FINAL
        exodus = true
[]        
