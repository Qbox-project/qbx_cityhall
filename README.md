# qb-cityhall
City Services for QB-Core Framework

## Dependencies
- [qb-core](https://github.com/QBCore-Remastered/qb-core) (Required)
- [ox-target](https://github.com/overextended/ox_target) (Optional)
- [ox_lib](https://github.com/overextended/ox_lib) (Required)
- [qb-phone](https://github.com/qbcore-framework/qb-phone) (Required)

## Features
- Ability to request id card when lost
- Ability to request driver license when granted by a driving instructor
- Ability to request weapon license when granted it by the police
- Ability to apply to government jobs
- Ability to add multiple cityhall locations
- Ability to add nultiple driving school locations
- Ability to take driving lessons
- Optional ox-target integration

## Installation
### Manual
- Download the script and put it in the `[qb]` directory.
- Add the following code to your server.cfg/resources.cfg
```
ensure qb-core
ensure ox-target # Optional
ensure qb-phone
ensure qb-cityhall
```
