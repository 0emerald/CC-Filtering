import glob, os
from warcio.archiveiterator import ArchiveIterator
import re # regular expressions
import csv
import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer
import numpy as np
import nltk
from nltk.tokenize import TweetTokenizer
nltk.download('punkt')
from scipy.io import mmwrite
from scipy.sparse import csr_matrix
import string
import sys

def postcode_finder(text):
    postcodes = re.findall(r'\b[A-Z]{1,2}[0-9][A-Z0-9]? [0-9][ABD-HJLNP-UW-Z]{2}\b', text)
    # https://stackoverflow.com/questions/378157/python-regular-expression-postcode-search
    return list(set(postcodes))

# function to find postcodes in the UK_PostcodeLookup
UK_PostcodeLookup = pd.read_csv('UK_PostcodeLookup.csv')
def UK_postcode_finder(text):
    postcodes = re.findall(r'\b[A-Z]{1,2}[0-9][A-Z0-9]? [0-9][ABD-HJLNP-UW-Z]{2}\b', text)
    postcodes = list(set(postcodes))
    # Filter postcodes to only include those found in UK_PostcodeLookup['pcds']
    matches = [postcode for postcode in postcodes if postcode in UK_PostcodeLookup['pcds'].values]
    if matches: 
        return matches

# function to extract website from url 
def extract_website(url):
    website =  re.sub(r'\.uk/.*', ".uk", url) # removes everything after .uk/ and the /
    website = website.replace("https://", "").replace("http://", "")
    return website

# Get the path of the current directory (used for opening file by filepath)
dir_path = os.path.dirname(os.path.realpath(__file__))

# loop over all files within directory that have .warc extension
for file_path in glob.glob(dir_path + "/*.wet"):

    # Access arguments passed from the Bash script
    arg1 = sys.argv[1]
    arg2 = sys.argv[2]
    cclocation = arg1 + arg2 # add the strings

    with open('outputdf.csv', 'w', newline='') as output_csv:
        csv_writer = csv.writer(output_csv)

        # open the file, naming the reader "stream"
        with open(file_path, 'rb') as stream:
            # loop over each record within "stream" using the ArchiveIterator from warcio
            for record in ArchiveIterator(stream):
                # Check if the current record has the type "response" - conversion as wet file
                if record.rec_type == 'conversion':
                    # lookup the uri (web address) of the record
                    uri = record.rec_headers.get_header('WARC-Target-URI')
                    language = record.rec_headers.get_header('WARC-Identified-Content-Language')

                    # check if the web address contains ".co.uk/" and the language is English
                    if ('.co.uk/' in uri) & (language == 'eng'):
                        website = extract_website(uri)
                        text = record.content_stream().read().decode('utf-8', 'ignore') # ignores symbols not in utf-8 
                        postcodes = UK_postcode_finder(text) # do postcode search for all UK postcodes
                        text = text.lower() # all into lowercase

                        if postcodes is not None:  # Check if there are any postcodes found
                            csv_writer.writerow([ uri,website,postcodes,cclocation,text]) ##cclocation
