## Units: cm-s-k
[Problem]
        coord_type = RZ
[]

[Mesh]
        [cladding]
             type = GeneratedMeshGenerator
             dim = 2
             nx = 50
             ny = 500
             xmin = 0.502
             xmax = 0.602
             ymin = 0
             ymax = 100.0
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
                ny = 500
                xmin = 0.5
                xmax = 0.502
                ymin = 0
                ymax = 100.0
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
                nx = 250
                ny = 500
               # xmin = 0.102
                xmax = 0.5  # 0.602
                ymin = 0
                ymax = 100.0
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
                function = ((500*((t/100)^0.5)*((1-(t/100))^4)+150)*cos((pi/(2*1.2))*((y/100)-1)))/(pi*0.5^2)
                variable = temperature
                block = 'fuel_block'
        []
[]

[BCs]
        [clad_right]
                type = FunctionDirichletBC
                variable = temperature
                function = ((350*cos((pi/(2*1.2))*((y/100)-1)))/(2*pi*0.5*2.65))+(((1/1.2)*((100*350)/(0.2*4670))*(sin(1.2)+sin(1.2*((y/100)-1))))+500)
                boundary = 'clad_right'
        []
        [fuel_left]
                type = NeumannBC
                variable = temperature
                boundary = 'fuel_left'
                value = 0 #adiabatic 
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
                thermal_conductivity = 0.03
                block = 'fuel_block'
        []
[]
                
[Executioner]
        type = Transient
        dt = 1
        end_time = 100
        nl_rel_tol = 1e-12
        nl_abs_tol = 1e-7
        dtmin = 0.5
[]

[VectorPostprocessors]
        [centerline-transient]
                type = PointValueSampler
                variable = temperature
                points = '0 25 0  0 50 0  0 100 0'
                sort_by = y
               # execute_on = TIMESTEP_BEGIN
        []
[]

[Outputs]
        exodus = true
        interval = 1
        [csv]
                type = CSV
        []
[]        
