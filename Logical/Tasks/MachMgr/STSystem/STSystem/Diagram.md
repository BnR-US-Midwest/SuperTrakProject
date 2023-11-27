Built with [Mermaid](https://mermaid.live/).

```mermaid
---
title: STSystem
---
stateDiagram
    classDef actingState stroke-dasharray:5
    state error_state <<join>>
    state execute_state <<join>>
    state stopped_state <<join>>

    [*] --> OFF
    OFF --> INITIALIZE : StartTrigger
    INITIALIZE --> error_state
    INITIALIZE --> IDLE : Active
    IDLE --> error_state
    IDLE --> execute_state
    IDLE --> STARTING : RunTrigger
    STARTING --> error_state
    STARTING --> execute_state
    EXECUTE --> error_state
    EXECUTE --> STOPPING: Stop
    EXECUTE --> stopped_state
    STOPPING --> stopped_state
    ERROR --> CLEARING: ResetTrigger
    CLEARING --> [*]

    error_state --> ERROR: Error
    execute_state --> EXECUTE: SectionsEnabled
    stopped_state --> IDLE: SectionsDisabled

    class INITIALIZE, STARTING, STOPPING, CLEARING actingState
```