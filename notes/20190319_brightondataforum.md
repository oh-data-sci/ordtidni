20190327 brighton data forum
===
# introduction
presenting a descriptive analysis of a mid-sized corpus.

- introduction to corpus analysis
- example code for processing large corpus in spark
- example nlp feature enginering:
    + part of speech/lemmatisation utilisation
    + word frequency
    + 
    + 

# output
## output for the corpus:

- number of documents
- number of paragraphs
- number of sentences
- number of words
- number of lemmas
- percentage of words that are:
    + nouns
    + pronouns
    + adjectives
    + adverbs
    + other
- table (csv):
    + lemma
    + word
    + part-of-speech
## output for each document:
- year
- source
- type of source
- number of paragraphs
- number of sentences
- number of lemmas
- number of words
- number of nouns
- number of pronouns
- number of adjectives
- number of adverbs
- average paragraph length
- average sentence length
- average word length


## output per word
- table 
    + lemma
    + number of documents occurring in
    + number of paragraphs occurring in
    + number of sentences occurring in
    + number of forms
    + length of lemma
    + average length of forms




---
# old
per malheild

    heildarfjoeldi skjala
    heildarfjoeldi ordha
    heildarfjoeldi lemma
    heildarfjoeldi setninga
    heildarfjoeldi malsgreina
    hlutfall hvers ordhflokks
    csv: lemma, ordh, ordhflokkur


per ordh:

    lemma, 
        fjoeldi skjala sem thadh kemur fyrir i,
        fjoeldi malsgreina sem thadh kemur fyrir i,
        fjoeldi setninga sem thadh kemur fyrir i,
        fjoeldi skipta sem thadh kemur fyrir i,
        fjoeldi ordhmynda,
        lengd lemmu,
        medhallengd ordhmynda,

per skjal

    lind,
    fjoeldi orhda
    fjoeldi setninga
    medhallengd setninga
    kyngreining
        nafnordh
        fornoefn
    fjoeldi nafnordha
    fjeoldi lysingarordha
    hlutfall ordhflokka
