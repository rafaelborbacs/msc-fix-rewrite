import pydicom
import sys
import os

# Get the file name from the command line
# We will extract the AE title from the DICOM file
filename = sys.argv[1]

# Read the file
dcm = pydicom.dcmread(filename)

# Get the metadata from the file and extract the AE_title
study_description = dcm.StudyDescription

print(study_description, end="")
