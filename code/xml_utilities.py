# helper functions for handling filesystem and tei:xml files

import os
import pandas as pd
import re
import xml.etree.ElementTree as et

NAMESPACE = {'tei': 'http://www.tei-c.org/ns/1.0'}

def scrape_directory_tree(starting_dir, file_ending='xml'):
    if starting_dir:
        try:
            assert os.path.isdir(starting_dir) # do not pass a filename
        except:
            print(starting_dir, 'is not a directory?')
            return None
    matching_files = []
    for current_dir, directories, files in os.walk(starting_dir, topdown=True):
       for filename in files:
           if filename.endswith(file_ending):
               matching_files.append(os.path.join(current_dir, filename))
    print('found', len(matching_files), 'files ending in', file_ending)
    return matching_files


def list_files_by_size(filepathlist, decreasing=True):
    sorted_files = sorted(filepathlist, key=os.path.getsize, reverse=decreasing)
    return sorted_files


def get_root_tag(xml_filepath):
    return et.parse(xml_filepath).getroot()


def get_text_paragraphs(xml_root,namespace=NAMESPACE):
    # given the root tag of a well formed tei xml file
    # assumes there is only a single div tag and returns
    # a list of paragraph tags inside
    text_pars = xml_root\
        .find('tei:text', namespace)\
        .find('tei:body', namespace)\
        .find('tei:div1', namespace)\
        .findall('tei:p', namespace)
    return text_pars


def get_text_divs(xml_root, namespace=NAMESPACE):
    # given the root tag of a well formed tei xml file, 
    # returns a list of the div tags in the text body.
    text_divs = xml_root\
        .find('tei:text', namespace)\
        .find('tei:body', namespace)\
        .findall('tei:div1', namespace)
    return text_divs


def get_div_paragraphs(text_divs, namespace=NAMESPACE):
    """
    given a list of div tags of a well formed tei xml file,
    returns a concatenated list of all paragraphs found in 
    all the divs
    """
    div_pars = []
    for div in text_divs:
        div_pars.extend(div.findall('tei:p', namespace))
    return div_pars


def get_paragraphs_sentences(text_paragraphs, namespace=NAMESPACE):
    """
    given a list of paragraphs of a well formed tei xml file,
    returns a full list of all sentences found in all the paragraphs
    """
    sentences = []
    for paragraph in text_paragraphs:
        sentences.extend(paragraph.findall('tei:s', namespace))
    return sentences


def get_sentence_lemmas(sentences, namespace=NAMESPACE):
    """
    given a list of sentences in a well-formed tei xml file, 
    returns all the lemmas found (and only the lemmas).
    """
    text_lemmas = []
    for sentence in sentences:
        for word in sentence.findall('tei:w',namespace):
            text_lemmas.append(word.attrib['lemma'].lower())
            #print(word.attrib['lemma'].lower())
    return text_lemmas


def get_sentence_words(sentences, namespace=NAMESPACE):
    """
    given a list of sentences in a well-formed tei xml file, 
    returns all the words found (and only the words).
    """
    text_words = []
    for sentence in sentences:
        for word in sentence.findall('tei:w',namespace):
            text_words.append(word.text.strip().lower())
            #print(word.attrib['lemma'].lower())
    return text_lemmas


def get_paragraph_lemmas(text_paragraphs, namespace=NAMESPACE):
    """
    given a list of paragraphs of a well formed tei xml file,
    returns all the lemmas found (and only the lemmas).
    """
    text_lemmas = []
    for paragraph in text_paragraphs:
        for sentence in paragraph.findall('tei:s', namespace):
            for word in sentence.findall('tei:w',namespace):
                text_lemmas.append(word.attrib['lemma'].lower())
                #print(word.attrib['lemma'].lower())
    return text_lemmas


def get_paragraph_words(text_paragraphs, namespace=NAMESPACE):
    text_words = []
    for paragraph in text_paragraphs:
        for sentence in paragraph.findall('tei:s', namespace):
            for word in sentence.findall('tei:w',namespace):
                text_words.append(word.text.strip().lower())
                #print(word.attrib['lemma'].lower())
    return text_lemmas


def get_sentence_lemma_word_pos(sentences, namespace=NAMESPACE):
    """
    given a list of sentences in a well-formed tei xml file, 
    this returns a dataframe of all lemmas, words, pos therein.
    """
    # prepare output dataframe:
    output_df = pd.DataFrame(columns=['lemma', 'word', 'pos'])
    text_lemmas = []
    text_words = []
    text_pos = []
    for sentence in sentences:
        for word in sentence.findall('tei:w',namespace):
            text_lemmas.append(word.attrib['lemma'].lower())
            text_words.append(word.text.strip().lower())
            text_pos.append(word.attrib['type'])

    output_df = pd.DataFrame(data={'lemma':text_lemmas,
                                   'word':text_words,
                                   'pos':text_pos})
    return output_df