SIMULATION
    SIMULATION_TYPE SUBSURFACE

    PROCESS_MODELS
        SUBSURFACE_FLOW Flow
            MODE GAS_WATER

            OPTIONS
                RESERVOIR_DEFAULTS
                ISOTHERMAL
                !HYSTERESIS
            END
        END
    END
END