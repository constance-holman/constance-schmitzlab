# Schmitz Lab in-vivo 

__Collaborators:__  
Viktor Bahr (viktor@eridian.systems),  
Constance Holman (constance.holman@gmail.com),  
Noam Nitzan (noam.nitzan@charite.de),  
Daniel Parthier (daniel.parthier@charite.de),  
John Tukker (john.tukker@charite.de)

## Description: 

This repository acts as a container for code, database models and queries, written in the course of the collaboration between Viktor Bahr ([Eridian System](https://eridian.systems)) and the SchmitzLab.

It's also kind of a demo repository for learning git - I'll try to keep it as clean as possible, but don't expect too much ;)

## Files & Folders (master branch):

- ``Readme.md`` is the file your're reading right now.
- ``import_remap_ephys.m`` is Noam / Constances current ephys data parsing script.
- ``read_Intan_RHD2000_file_jt.m`` parses _Intan Technologies_ amplifier data.
- ``sql/`` folder containing MATLAB sql wrapper functions.
    - ``init.m`` initialize database create queries in as MATLAB struct variable.
    - ``create_table.m`` wrapper function to create tables, uses variable created by ``init.m``.
    - ``drop_table.m`` wrapper function for dropping tables, also uses variable created by ``init.m``.
    - ``ìnsert_project.m`` wrapper function for inserting a row into the ``Project`` table
    - ``ìnsert_animal.m`` wrapper function for inserting a row into the ``Animal`` table
    - ``ìnsert_experiment.m`` wrapper function for inserting a row into the ``Experiment`` table
    - ``ìnsert_session.m`` wrapper function for inserting a row into the ``Session`` table
    - ``insert_amplifier.m`` wrapper function for inserting a row into the ``Amplifier`` table
    - ``insert_probetype.m`` wrapper function for inserting a row into the ``ProbeType`` table
    - ``database.mwb`` mysql-workbench model of the database; for query creation and visualization.
