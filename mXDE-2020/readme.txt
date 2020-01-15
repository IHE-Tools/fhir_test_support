These are notes to remind one how to use the scripts
  in this folder to generate and store data.
There is a separate regression.txt file with instructions
  on regression tests.

* cd scripts

* edit the file: base_url.sh
**  Set the URL in this file to the value of your FHIR server
**  All other scripts will use this definition, so you can set it once

* edit the file: master_setup.sh
** At the bottom of the script, make sure it references the proper patient
** Make sure that patient file has the proper patient identifier

* ./master_setup.sh

* ./master.sh
** This will create and push resources to your FHIR server
    1 Patient
    1 Organization
    1 Location
    3 Encounter
    3 DocumentReference
   20 Observation
   23 Provenance
** Make note of the FHIR ID of the patient that is created.
   This is in the file: ../tmp/patient.id.txt
   You will need this in further steps.
   Yes, there should be better automation

* Edit the hand generated condition resources
** ../hand_generated/conditions
* Alter the reference for the subject to use the correct FHIR Patient ID

* ./post_conditions.sh
** See regression tests

