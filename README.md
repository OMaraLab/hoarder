# HOARDER.sh: a Helpful OMara to ACSC-Repository Dataset Efficient Reshaper

`Hoarder.sh` is a script to automatically reshape a molecular dynamics simulation from a typical OMara group directory structure into a directory structure suitible for the [Australasian Computational Simmulation Commons](https://molecular-dynamics.atb.uq.edu.au).  After a dataset is processed with HOARDER, it should be validated and archived with [CSC tools](https://atb-uq.github.io/csc-tools/), and submitted to the repository.

## Intended workflow

Hoarder assumes your production simulation looks something like this:

~~~text
└──System_Name
    ├── Forcefield.ff                # location of this folder varies from system to system
    |   └──Various itp files         # forcefield parameter files
    |
    ├── run1                         # folder for a simulation replicate
    |   ├──System_Name               # a submission script for SLURM or PBS
    |   ├──System_Name_start.gro     # input coordinates
    |   ├──System_Name.edr           # energy file (optional)
    |   ├──System_Name.gro           # final coordinates
    |   ├──System_Name.log           # log file
    |   ├──System_Name.mdp           # control file
    |   ├──System_Name.ndx           # index file
    |   ├──System_Name.top           # topology
    |   ├──System_Name.tpr           # gromacs binary input file
    |   ├──System_Name.trr           # very large trajectory file (optional)
    |   ├──System_Name.xtc           # compressed trajectory file
    |   ├──Extra_itp_file_1.itp      # extra forcefield parameter files that were stored 
    |   └──Extra_itp_file_2.itp         outside the forcefield folder (optional)
    |
    ├── run2                         # folder for a second simulation replicate
    |   └──Similar contents to run1
    |
    └── run3                         # folder for a third simulation replicate
        └──Similar contents to run1 and run2
~~~

A typical workflow would be:

* **First**, use hoarder to restructure each simulation replicate.
* **Second**, manually check the metadata and contents of the forcefield folders to ensure everything has been captured correctly, and remove anything that is not required.  This might include `.itp` files that were not used in the production simulation, or leftover python scripts and juptier notebooks left in the forcefield folder.
* **Third**, use [csct](https://atb-uq.github.io/csc-tools/) to validate and archive each restructured simulation replicate
* **Finally**, upload the archived datasets to the [Australasian Computational Simmulation Commons](https://molecular-dynamics.atb.uq.edu.au).

Note that each simulation replicate needs to be handled as a separate system.

## Useage

A typical command might look like this:

~~~s
$ ./hoarder.sh -i System_Name -p path/to/production_system/rep1                ;
    -o Output_SystemName -q path/to/outputdataset/  --rep 1 --reps 3           ;
    -f path/to/forcefield_folder.ff --extra_itp path/to/Extra_itp_file_1.itp   ;
    --extra_itp path/to/Extra_itp_file_2.itp 
~~~

This would archive the simulation replicate found in the folder `path/to/production_system/rep1`, by looking for system files that match the simulation structure described above.  It would copy the system as a restructured dataset in the directory `path/to/outputdataset/Output_SystemName`

### Important options

* `-h` : print the help
* `--dry-run` : test whether the files and paths specified in your command are valid, and whether any required flags are missing, then exit without doing anything.
* `--notrj` : copy and restructure the dataset as normal but do not copy any trajectory data
* `--notrr` : copy and restructure the dataset as normal but do not copy any `.trr` trajectory files.  This is useful if your simulation includes a large, reduntant `.trr` file that you do not wish to archive.

## Naming your system

Every datasets on the ACSC needs to have a unique system name, not shared with any other repository from any other research group.  To accieve this, our group convention for output system names is: `OMara_[ProjectName]_[ProjectYear]_[SystemName]_r[ReplicateNumber]`

So for example, replicate 2 of a system containing tail-oxidised cholesterol from [this paper](http://doi.org/10.1021/acschemneuro.1c00395) might be called `OMara_OxidisedNeuronal_2021_tailOHC_r2`

## Generating metadata

`hoarder.sh` will attempt to generate metadata for you automatically in a file called `atbrepo.yaml`.  It will look something like this:

~~~yaml
title: "This will appear as the title of the simulation on the ACSC website. Should be enclosed in quotation marks. {replicate TKTKTK of KTKTKT}"
notes: "This will appear as a description of the simulation on the ACSC website. Should be enclosed in quotation marks.  If the data is related to a publication, the DOI of the publication can also be included in this field. {replicate TKTKTK of KTKTKT}"
program: GROMACS
organization: omara
tags:
    - replicate-TKTKTK of KTKTKT
    - forcefield-[forcefield name and version]
    - membrane-[type of membrane]
    - PDB-[pdb code]
    - protein-[example name of protein]
    - peptide-[example name of peptide]
    - lipid-[example name of lipid]
THE NEXT LINES ARE TAGS FOR EVERY MOLECULE IN THE SYSTEM.  CHANGE THEM from molecule-MOLNAME to whatever type of molecule they are, eg "lipid-POPC" or "solvent-PW" or "protein-GlyT2".  Remove this line when complete, and the example molecule tags above
    - molecule-Protein_Chain_A
    - molecule-CHOL
    - molecule-OCLR
    - molecule-POPC
    - molecule-DPSM
    - molecule-DPPC
    - molecule-PUPE
    - molecule-DPGS
    - molecule-PAPC
    - molecule-PAPE
    - molecule-DOPC
    - molecule-PUPC
    - molecule-POPE
    - molecule-PNSM
    - molecule-PBSM
    - molecule-PNGS
    - molecule-DPG1
    - molecule-DPG3
    - molecule-DBGS
    - molecule-OAPE
    - molecule-OUPE
    - molecule-POSM
    - molecule-PFPC
    - molecule-OIPC
    - molecule-POGS
    - molecule-OUPC
    - molecule-DPCE
    - molecule-PADG
    - molecule-DBG1
    - molecule-PNG1
    - molecule-DBG3
    - molecule-PNG3
    - molecule-PPC
    - molecule-OIPE
    - molecule-POG1
    - molecule-POG3
    - molecule-DBCE
    - molecule-PNCE
    - molecule-IPC
    - molecule-PPE
    - molecule-IPE
    - molecule-PODG
    - molecule-PUPS
    - molecule-PAPS
    - molecule-POPS
    - molecule-PUPI
    - molecule-POPI
    - molecule-PAPI
    - molecule-OUPS
    - molecule-DPPS
    - molecule-PIPI
    - molecule-PAPA
    - molecule-PAP1
    - molecule-PAP2
    - molecule-PAP3
    - molecule-POP1
    - molecule-POP2
    - molecule-POP3
    - molecule-POPA
    - molecule-PW
    - molecule-NA+
    - molecule-CL-
~~~

You will need to manually edit this to provide a dataset title, some human readable notes about your dataset, and metadata tags describing your simulation.

This is what that metadata file might look like after you finish editing it.  There is now an  informative title, a brief but detailed description of the simulation including the DOI of the relevant publication, notes specifying the simulation software used (Gromacs) and the group that owns the dataset (the O'Mara group), and metadata tags describing the simulation paramaters and listing relevant molecules.

~~~yaml
title: "Complex neuronal membrane with 10% ring-oxidised cholesterol {replicate 3 of 3}"
notes: "A coarse-grained simulation of a complex neuronal membrane containing ~50 different lipid species. Cholesterol has been replaced with ring-oxidised cholesterol to yield 10 mol% ring-OHC. This replicate was simulated for 20 µs with a 25 fs timestep, using Gromacs 2019.4. This system relates to the publication 'Site of Cholesterol Oxidation Impacts Its Localization and Domain Formation in the Neuronal Plasma Membrane', by Katie A. Wilson, Lily Wang, and Megan L. O’Mara, doi 10.1021/acschemneuro.1c00395  {replicate 3 of 3}"
program: GROMACS
organization: omara
tags:
    - replicate-3 of 3
    - forcefield-Martini 2.2P
    - complex membrane
    - lipid fingerprint
    - neurotransmitter sodium symporter
    - complex membrane
    - membrane-complex neuronal
    - membrane-oxidised complex neuronal
    - protein-GlyT2
    - protein-SLC6A5
    - uniprot-Q761U9
    - lipid-CHOL
    - lipid-OCLR
    - lipid-POPC
    - lipid-DPSM
    - lipid-DPPC
    - lipid-PUPE
    - lipid-DPGS
    - lipid-PAPC
    - lipid-PAPE
    - lipid-DOPC
    - lipid-PUPC
    - lipid-POPE
    - lipid-PNSM
    - lipid-PBSM
    - lipid-PNGS
    - lipid-DPG1
    - lipid-DPG3
    - lipid-DBGS
    - lipid-OAPE
    - lipid-OUPE
    - lipid-POSM
    - lipid-PFPC
    - lipid-OIPC
    - lipid-POGS
    - lipid-OUPC
    - lipid-DPCE
    - lipid-PADG
    - lipid-DBG1
    - lipid-PNG1
    - lipid-DBG3
    - lipid-PNG3
    - lipid-PPC
    - lipid-OIPE
    - lipid-POG1
    - lipid-POG3
    - lipid-DBCE
    - lipid-PNCE
    - lipid-IPC
    - lipid-PPE
    - lipid-IPE
    - lipid-PODG
    - lipid-PUPS
    - lipid-PAPS
    - lipid-POPS
    - lipid-PUPI
    - lipid-POPI
    - lipid-PAPI
    - lipid-OUPS
    - lipid-DPPS
    - lipid-PIPI
    - lipid-PAPA
    - lipid-PAP1
    - lipid-PAP2
    - lipid-PAP3
    - lipid-POP1
    - lipid-POP2
    - lipid-POP3
    - lipid-POPA
    - solvent-PW
    - solvent-Martini 2 PW
    - ion-Na+
    - ion-Sodium
    - ion-Ca-
    - ion-Calcium
~~~

## Metadata guidelines

### Metadata title

This should be a short, human-readable title, that informs the user what the simulation was about.  It should end with the replicate number in the format `{replicate X of Y}`.

### Metadata notes

This should be a short human readable description the system.  If the simulation was published, this should include the DOI of the relevant paper.  this should be only a brief summary of what the simulation system is; don't include exessive detail as this is present in the paper.  It should also end with the replicate number in the format {replicate X of Y}.

### Metadata tags

`hoarder.sh` will scan your top file and generate a metadata tag for every molecule listed in your `.top` file.  This is a guess, and you should inspect it manually and decide what you actually want.  These will be in the form `- molecule-RESNAME`.  For molecules that are proteins, peptides, solvents, or lipids, you will need to edit these to the correct molecule type.

At the bare minimum, this should include:

* the forcefield used, including version number
* the replicate number of this system
* keywords relevant to your system (eg; complex membranes, bacterial membranes, neurotransmitter transporter, drug delivery polymer).  There is no convention for how keywords work, but please make sure your keywords are consistent from system to system.
* the name of any proteins in your system
* if you use a protein structure from the PDB, you should include the PDB code
* the type of membrane studied in your system
* any organisms relevant to your system (eg:  MRSA)
* any molecule used in your system that might be relevant.

The automatically generated tags are a starting point.  You will need to edit them.

Some general guidelines about metadata are given below.  You may also wish to look at the conventions listed [here](https://atb-uq.github.io/csc-tools/dataset_metadata.html).

* If a molecule has one or more common names, you may wish to include a tag for those.   This is a judgement call, and depends on how relevant the molecule is to the purpose of your system. For example, if your system is about studying the difference between cholesterol and ring-oxidised cholesterol, you might want these metadata tags:

~~~yaml
    - lipid-CHOL
    - lipid-cholesterol
    - lipid-OCLR
    - lipid-ring-OHC
    - lipid-ring-oxidised cholesterol
~~~

* A tag related to a protein should be tagged as `-protein-protein name`.  For example, if your protein was GlyT2 and the tag generated by your top file was `- molecule-protein_chain_A`, you would change it to `- protein-GlyT2`

* You should also include other commonly used references to your protein, such as a uniprot id.  For human GlyT2, you would also include `- protein-SLC6A5` and `- uniprot-Q761U9`

* If your protein structure came from the PDB, include a tag for the four letter pdb code.  for example, if your simulation used [this PDB structure of *Drosophila* DAT](https://www.rcsb.org/structure/4m48) you would include the tag `- pdb-4M48`.

* If your system includes solvent, uou should have a tag related to the specific solvent model used.  For example, if you used the SPC water model, you would change `- molecule-SOL` to `- solvent-SPC`.  If you used martini polarizable water, you might use `- solvent-Martini 2 PW`.  If you used martini2 coarse grain water with antifreze, you might use `- solvent-Martini 2 W` `- solvent-Martini 2 WF`.  

* A tag related to an ion should be changed to `- ion-ionname`.  For example, divalent calcium would change from `- molecule-Ca` to both `- ion-Ca2+` and `- ion-calcium`

* A tag related to a lipid should be changed to `- lipid-lipidcode`.  For example, `- molecule-POPC` should become `- lipid-POPC`

* A tag related to a peptide should be chaned to `- peptide-peptidename`

* A tag related to a polymer should be chaned to `- polymer-polymername`

* A tag for a molecule that doesn't fit into one of these categories, such as a small molecule inhibitor compound, should remain as `- molecule-RESNAME`.  Again, you may wish to include relevant common name(s) if any exist.

**Q: Why have you decided to generate a metadata tag for every lipid in your system?  That's so many molecules.**

**A:**  How often have you had to scour the martini website for parameters for a particular unusual lipid?  Wouldn't you like to be able to search this repository and find published parameters for your molecule of interest?

**Q: I want to make a tag that's relevant to my system, but there are no guidelines for my particular tag.**

**A:**  Congratulations!  You get to make something up!  Try to align with existing conventions.  If it's a tag you think other people will need to use, let me know and I'll add it to this document.
