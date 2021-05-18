MECPro Version 1.0.6: July 1, 2020

==---
Foreword
========---

MECPro is a Python program designed to located so-called Mimimum Energy Crossing 
Points (MECP) where two spin states have degenerate moleuclar strucutres and energies. 
This Python program was developed based on a previous program written by Jeremy Harvey (KU Leuven).

If you have any questions, comments, bug reports, or feature requests, 
email Daniel Ess (dhe@chem.byu.edu).

Program Authors: Justin D. Snyder, Lily H. Carlson, Kavika E. Faleumu, and Daniel H. Ess

Please site the use of this version as: 
MECPro Version 1.0.6: Minimum Energy Crossing Program (2020), Justin D. Snyder, Lily-Anne Hamill, Kavika E. Faleumu, Allen R. Schultz and Daniel H. Ess

======---
Installation
============---

BYU Installation Instructions:
1) Copy mecpro directory into your home directory. 
2) make all the files in the scripts directory executable (e.g. use chmod). 
3) Include in your .bashrc module load python/3.7.
4) to your .bash_profile add the following
export MECPRO_HOME=/homedirectory/mecpro
PATH=$PATH:"$MECPRO_HOME"/scripts
PATH=$PATH:"$MECPRO_HOME"/pylib
PATH=$PATH:"$MECPRO_HOME"/templates

===============---
Tools in this package
=====================---

mecpstart: Creates submission scripts and instantly submits jobs to the
supercomputer. Eliminates the need to manually create job scripts, thus saving
you a minute or two per job. Very flexible options and easy to interface with
other scripts. To run mecpstart, navigate the to the directory that contains
the .mecp file you want to run, and type the command where the jobname does
not include the .mecp suffix:
  > mecpstart <jobname>

More information on mecpstart usage to follow.

mecpsubmit : Grabs all mecp jobs in your current directory and runs mecpstart
on them all. Makes it easier to run a large number of jobs with similar specifications
( hours, cores, memory ) at once rather than each individually. Will prompt the
user once for specifications and will use these values for all jobs.
  > mecpsubmit

mecpstatus : Returns the status of a job. You can choose to check the status
of a single directory using the -d flag. Without the flag, the script will 
check the status of all the subdirectories in the current directory. Will
recursively go through all subdirectories through the directory tree.
It will only tell you which jobs have converged. If you want more information on
the status of all jobs, then you can add the -v flag to output more information.
To run mecpstatus navigate to the run_outputs directory and use the command:
  > mecpstatus
  > mecpstatus -d [subdirectory]
  > mecpstatus -v
If you have a previous version of MECPro, mecpstatus will still work outside
the run_outputs directory. Preferably used in run_outputs or the mecp directory
since this is where all of your jobs will be sent.

mecpnext : If a convergence was not found, or the job did not finish, mecpnext
will use mecpstart to continue the job from the last step in the same directory, 
and concatenate to the same <jobname>.log file. You must run mecpnext within the 
directory of the job you want to continue.
	> mecpnext [jobname]

mecpdata : This script will generate a <jobname>.csv file from the <jobname>.log 
file. It will extract Step, Energy of First Spin State, Energy of Second Spin State, 
Difference in Energy, Max Gradient, RMS Gradient, Max Displacement, and RMS 
Displacement.
  > mecpdata -f [jobname.log]
  
mecpxyz : This script grabs the initial and final geometries from all finished mecp
job in your current directory and puts the geometries into seperate .gjf files 
(*-initial.gjf and *-final.gjf) to be viewed in GaussView. You can also specify
the -f flag to only run for a single specified log file. It will also print out
the final energy of the first and last spin states.
  > mecpxyz
  > mecpxyz -f [jobname.log]

===========---
Input file format
=================---

Input files for this program are somewhat free-format, but can easily resemble a
gaussian input file. At the same time, they were designed with the idea of being
easy to generate- in fact, unfinished jobs will create an input file you can run
to resume the calculation. They will look ugly and will be in a strange order.
That is normal behavior that happens because of the way inputs were implemented.

An input file is divided into "sections," which are most easily designated with
square brackets. (e.g. [geometry]) Section headers are not case sensitive (e.g.
GEOMETRY is the same as geometry and GeoMeTrY). A section ends where another
begins. Some sections can be "inlined" into other sections or can be started
with alternate notations so that inputs can closely resemble typical inputs for
Gaussian.

Some sections have no special format and are just "parameter" sections. They
simply contain a list of parameters and their values. Many of these have
defaults. Parameters can be set with :, =, or whitespace. For example, all of
these formats are valid ways to set a parameter:
method = um06/gen
maxsteps: 20
maxstepsize 0.2

We highly recommend using the examples as a reference when creating your job.

SECTIONS:

[General] (Parameter Section)
This allows you to set general parameters for the run.
Available parameters:
method:     	The basis set used in calculations, one for each of the spin
                states. If you do not give a or b, it will use the same basis set
                for both spin states. The program expects a "u" DFT method to be
                used. (defaults to um06l/gen)
charge:         The charge of the molecule (defaults to 0)
spinstates:     The spin states to use in calculation. This value should be two
                numbers delimited by a forward slash (/). (defaults to 1/3)
read_later:     When set to true/on, causes all steps after the first to have
                'guess=read' set for the route. This will NOT override your initial
                guess setting and will reflect itself in the resumable inputs
                (the '.next.mecp' file). A singlet for example will have 
                guess=(mix, read) in the route line. (defaults to false/off)
max_steps:      The maximum number of steps to find a convergence (default: 40)
max_stepsize:   The maximum geometry displacement per step (defaults to 0.1)
pre_opt:        Do a standard geometry optimization before doing the rest of the
                calculation. Give it a spin state and a method/basis set to work
                with, space separated. You can provide 'a' or 'b' for the spin
                state, indicating to use whichever one is used by the first or
                second states, respectively. If you have included the guess 
                keyword in your route, it will delete that keyword to perform
                the optimization.(defaults to "none m06/gen")
show_hessian:   Shows information about the hessian matrix at each step. Valid
                settings are 'none', 'full', and 'sign'. The 'sign' setting will
                show only the sign of the hessian, rather than the values.
                (defaults to none; this is primarily a debug feature.)

[Link] (Parameter Section)
This allows you to specify the LINK0 (% lines) section in the gaussian inputs.
You can also "inline" lines from this section by starting a line with a %.

You do not need to specify the chk. It will be automatically named, and in fact,
will be overridden even if you try to set it.

[Route]
You can now include your basis here, so inputs are no longer much different at
all from Gaussian input files. The program will check for and eliminate
redundancy, however, this operates under the assumption that anything with a /
in it is the method/basis, so this may screw up some existing inputs.

This allows you to customize the route card (# line) in the generated gaussian
input files. It defaults to include "force" and "integral=ultrafinegrid". In 
addition, the default will add "guess=mix" to any singlet. If you specify a 
different guess option it will be combined with mix for the singlet. For example,
if you use guess=read for both spin states, the singlet will force 
guess=(mix, read) to be used on the route line. 

All other options should be specified manually.

Each line includes a single option for the route line. If an option should
only be used for one of the spin states, you can prefix a line with A: or 
B: to signify the first and the second spin states, respectively.

You can also "inline" this section into anywhere in the file by using a line
that starts with # for both states a# for the first state only, and b# for the
second state only. Such lines may include multiple options.

[Cutoffs] (Parameter Section)
This section allows you to customize your convergence criteria.
The available parameters are:
max_grad: the largest component of the gradient (defaults to 0.0007)
rms_grad: the root mean square of the gradient  (defaults to 0.0005)
max_chg:  the largest component of displacement (defaults to 0.004)
rms_chg:  the root mean square of displacement  (defaults to 0.0025)
energy_diff: the difference in energy of the two states (defaults to 0.00005)
If a job is not converging, consider loosening the cutoff parameters.

[Geometry]
The most important part and the only essential part of the file. Include your
atoms and their coordinates in their usual way. It will work with both atomic
numbers and atomic symbols. (You should even be able to mix and match if you are
crazy like that)

An alternate way to begin this section is with a line matching the pattern
# #/#
Where the #s are numbers. The first one sets the charge, the second two set the
spin states.

Unlike other sections, this one may be ended with a blank line, at which point,
it starts an [extra] section.

[Extra]
This section allows you to put extra lines after your geometry.

=========---
mecpstart Usage
===============---

To submit a Gaussian job (.com) to the supercomputer, run the following command:
 > mecpstart <jobname>
(Where jobname is the name of your .com file, without the .com)

As soon as you run it, it will prompt you for how many hours you need to run
your job, how many cores you need, and how much memory you want.
When this is run, it will make a new folder for your job, copy your input file
into it, prepare a .sh file, and then submit the .sh to the supercomputer.

Here are some "Advanced" command-line options for those of you who are
comfortable with running complex commands...

Here are the most notable options:
 > mecpstart -e <email> <jobname>  # Emails you when the job is done/terminated
 > mecpstart -d <path/to/directory> <jobname>

Other options are mostly ideal for interfacing with scripts, as many of them
allow you to bypass the prompting of parameters.

This is the "detailed" usage statement given when -h is given as an option:
USAGE:  mecpstart [options] [job]

Available options:
        -H <hours>      Sets the walltime, and does not ask for it anymore.
        -c <cores>      Sets how many cores you wish to request.
        -m <mem>        Sets how much memory (in GB) is needed per processor
        -d <dir>        Sets the directory that this will create.
        -e <email>      Emails the given email when the job completes or is stopped.
        -n              Do not clean up the submission directory.
        -i              Interactive mode. Will prompt for nodes, cores and
                        memory and confirm sending the script. (default behavior)
        -I              Non-interactive mode: Use the default options instead of
                        prompting for them.
        -s              Generate script only. Do not submit it to SLURM.
        -t              Designates this as a test job
        -h              Show this help screen and exit.
If you do not provide a job, you will be prompted for one instead.

=========---
Examples
===============---

Two example input files are included with this package. Both examples take less
than an hour to run. (You can really expect it to take around 10 minutes)

Navigate to the mecpro/examples directory.

example1.mecp
This lists all the available parameters with their titles. Run it with the command:
 > mecpstart example1
Follow the prompts you are given. The job will finish in about 5 minutes and will not
converge because it has a maximum of 4 steps. Check for convergence with the command
 > mecpstatus -d example1
To continue the job navigate into mecpro/run_outputs/example1 and run the
command:
 > mecpnext example1
Follow the prompts and the job will continue and converge.

example2.mecp
This is a different geometry from example1, and formatted slightly differently.
You still use the same commands to run it. With this advanced command you will
get an email when it finishes:
 > mecpstart -e <your email> example2 
When it finishes navigate to mecpro/run_outputs and run the command:
 > mecpstatus
This will show the status of all directories inside the run_outputs folder.
Navigate into the mecpro/run_outputs/example2 folder. To extract data about the 
path taken to reach the MECP, you can use the following command:
 > mecpdata -f example2.log
This will create an example2.csv file that contains information about each
step.

Notice example2-error.mecp is an example of a file that will fail.
You may test them if you want to see what an error looks like.

=========---
Output Files
===============---

Suppose you have a run named foo.mecp. 
You may see any of the following output files:

  foo.mecp          Submission file
  foo.mecp.origin   If the job does not converge and you choose to continue, this 
                    file contains your original submission, while foo.mecp will 
                    contain the point the job most recently continued from.
  foo.log           Information about the calculations at each step and 
                    whether convergence criteria has been met is listed here, and
                    the script mecpdata will pull its data from here.
  foo_A0.com        There will be a .com and .log file for each molecule at each step 
                    (foo_A0.log, foo_B0.com, foo_B0.log, foo_A1.com, ...) If the job
                    converges, you can expect to look at the com file of the last step
                    of either spinstate to find the final geometry.
  foo-opt.com       If pre_opt is chosen, there will be a -opt.com and -opt.log file
                    from the resulting optimization calculation.
  foo_A.chk         For both molecule A and B a checkpoint file is used for 
                    calculations.
  foo.csv           Generated by mecpdata
    
